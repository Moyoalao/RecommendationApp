import pandas as pd
import numpy as np
import requests
import ast
import random
import time
import firebase_admin
from scipy.sparse import isspmatrix, vstack
from firebase_admin import credentials, firestore
from sklearn.preprocessing import MultiLabelBinarizer
from sklearn.feature_extraction.text import TfidfVectorizer
from scipy.sparse import hstack,isspmatrix
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Dropout, Input



#intiialize firebase connection
def initialize_firebase():
    try:
        #check if firestore already initialized
        default_app = firebase_admin.get_app()
    except ValueError:
        #if fire base is not already initlized
        cred = credentials.Certificate('RecommendationApp/Other/recommendationapp-530d6-firebase-adminsdk-401fv-e61da95e16.json')
        default_app = firebase_admin.initialize_app(cred)
    #retutn firestore client
    return firestore.client()
    
#initialize connection and stores client in db
db = initialize_firebase()

#handles http response retries on rate limit errors
def safe_api_call(url, api_key):
    attempts = 0
    while attempts < 5:
        #api request with url and key
        response = requests.get(f"{url}&api_key={api_key}")
        if response.status_code == 200:
            #returns json on succes
            return response.json()
        elif response.status_code == 429:  # Rate limit exceeded
            retry_after = int(response.headers.get('Retry-After', 60))
            print(f"Rate limit exceeded. Retrying after {retry_after} seconds")
            #pause execuation before retrying
            time.sleep(retry_after)
        else:
            print(f"Failed request: {response.status_code}")
        attempts += 1
    return {}
# fetches detailed information about a specific movie from TMDB(The Movie Database) api
def fetch_movie_details(movie_id, api_key):
    url = f'https://api.themoviedb.org/3/movie/{movie_id}?language=en-US'
    return safe_api_call(url, api_key)
# fetches a list of movies similar to a given movie id using TMDB api
def fetch_similar_movies(movie_id, api_key, language='en-US'):
    url = f'https://api.themoviedb.org/3/movie/{movie_id}/similar?api_key={api_key}&language={language}'
    response = safe_api_call(url, api_key)
    if response and 'results' in response:
        similar_movies = response['results']
        # Check the structure of the first movie (if exists)
        if similar_movies:
            return similar_movies
    else:
        print("No similar movies found or bad response.")
        return []
# fetches a predefined number of movies in batches by iterating through pages of api responses
def fetch_additional_movies(api_key, number_of_movies=250):
    movies_data = []
    page = 1
    while len(movies_data) < number_of_movies:
        url = f"https://api.themoviedb.org/3/discover/movie?language=en-US&page={page}"
        page_movies = safe_api_call(url, api_key)
        if page_movies:
            movies_data.extend(page_movies.get('results', []))
           #break if last page reached
            if 'total_pages' in page_movies and page >= page_movies['total_pages']:
                break
        else:
            print(f"Failed to fetch movies on page {page}")
            break
        page += 1
    return movies_data[:number_of_movies]

# get the users watchlist from the firestore database using their id
def get_user_watchlist(user_id, db):
    try:
        watchlist_ref = db.collection('watchList').document(user_id).collection('movies')
        docs = watchlist_ref.stream()
        return [doc.to_dict() for doc in docs]
    except Exception as e:
        print(f"Failed to fetch watchlist: {e}")
        return []

#cleans and processes movie data
def clean_data(df):
    #fill missing genre column with empty list
    df['genres'] = df['genres'].fillna('[]')
    #fill missing values in overview column with
    df['overview'] = df['overview'].fillna('')
    # Safely convert string representations of lists in 'genres' to actual list objects
    df['genres'] = df['genres'].apply(lambda x: ast.literal_eval(x) if isinstance(x, str) else x)
    #all overview is string
    df['overview'] = df['overview'].astype(str)
    return df

#reads csv file in batch size for handling large datasets
def load_csv_data_in_batches(filepath, batch_size=10000):
    try:
        #go over csv in chunks
        for df_chunk in pd.read_csv(filepath, chunksize=batch_size):
            # clean each chunk before processing
            df_cleaned = clean_data(df_chunk)
            yield df_cleaned
    except Exception as e:
        print(f"Error loading data in batches: {e}")

# Modify the function to setup transformers to properly handle genres
def setup_transformers():
    # load a sample batch of movie metadata to fit the transformers
    sample_batch = next(load_csv_data_in_batches('RecommendationApp/Other/movies_metadata.csv', batch_size=8500))
    # get genre names from the 'genres' column, handling missing or malformed data
    genres = sample_batch['genres'].apply(lambda x: [g['name'] for g in x if 'name' in g])
    mlb = MultiLabelBinarizer()
    mlb.fit(genres)

    # initialize and fit a TfidfVectorizer to movie overviews for feature extraction
    vectorizer = TfidfVectorizer(max_features=100)
    vectorizer.fit(sample_batch['overview'])

    return mlb, vectorizer

def generate_user_profile(user_watchlist, genre_encoder, tfidf_vectorizer,api_key):
    genre_vectors = []
    overview_vectors = []
    for movie in user_watchlist:
        #get detailed information for each movie in the watchlist
        movie_details = fetch_movie_details(movie['id'], api_key)
        #extract genres and convert into encoded vectors
        genre_list = [g['name'] for g in movie_details.get('genres', []) if 'name' in g]
        genres_input = genre_encoder.transform([genre_list])
        overview_input = tfidf_vectorizer.transform([movie_details.get('overview', '')])

        # Convert sparse matrices to dense if necessary
        if isspmatrix(genres_input):
            genres_input = genres_input.toarray()
        if isspmatrix(overview_input):
            overview_input = overview_input.toarray()

        genre_vectors.append(genres_input)
        overview_vectors.append(overview_input)

    if not genre_vectors or not overview_vectors:
        print("No data to create profile vectors.")
        return None

    # Aggregate and average the genre and overview vectors to form a user profile
    user_genre_profile = np.mean(np.vstack(genre_vectors), axis=0) if genre_vectors else np.array([])
    user_overview_profile = np.mean(np.vstack(overview_vectors), axis=0) if overview_vectors else np.array([])

    # Combine both genre and overview profiles into a single vector
    user_profile = np.hstack([user_genre_profile, user_overview_profile])

    return user_profile


def score_movies(candidate_movies, user_profile, model, genre_encoder, tfidf_vectorizer):
    scored_movies = []
    if user_profile is None or user_profile.ndim != 1:
        print("Invalid user profile dimension.")
        return scored_movies

    user_profile = user_profile.reshape(1, -1)  # ensure 2D for subtraction

    for movie in candidate_movies:
        # Encode genres and overview text for each movie
        movie_genre_input = genre_encoder.transform([[g['name'] for g in movie.get('genres', []) if 'name' in g]])
        movie_overview_input = tfidf_vectorizer.transform([movie.get('overview', '')])
        movie_input = hstack([movie_genre_input, movie_overview_input]).toarray()
        # the absolute difference between the movies and the users profile
        combined_input = np.abs(movie_input - user_profile)
        # Predict the relevance score using the model
        predicted_score = model.predict(combined_input)[0][0]
        scored_movies.append((movie['title'], predicted_score, movie['id']))
    return scored_movies


def prepare_input(genres, overview, genre_encoder, tfidf_vectorizer):
    # Encode the genres
    genres_input = genre_encoder.transform([genres])
    
    # Encode the overview
    overview_input = tfidf_vectorizer.transform([overview])
    
    # Combine both inputs
    movie_input = hstack([genres_input, overview_input]).toarray()
    
    return movie_input

# Create TensorFlow model
def create_model(input_dim):
    model = Sequential([
        Input(shape=(input_dim,)),#  specify the dimension of input
        Dense(256, activation='elu'), #layer with 256 neurons and ELU activation
        Dropout(0.5),# dropout layer for regularization
        Dense(128, activation='elu'),#layer with 128 neurons and ELU activation
        Dense(1, activation='sigmoid') # output layer with a sigmoid activation for binary classification
    ])
    model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])
    return model


def train_model(filepath, vectorizer, genre_encoder, epochs=5):
    first_pass = True
    model = None
    input_dim = None

    for df_chunk in load_csv_data_in_batches(filepath):
        # process and encode genres and overviews for each chunk of data
        genres_encoded = genre_encoder.transform(df_chunk['genres'].apply(lambda x: [g['name'] for g in x if 'name' in g]))
        overview_encoded = vectorizer.transform(df_chunk['overview'])

        if first_pass:
            # determine the input dimension from the first batch and initialize the model accordingly
            input_dim = genres_encoded.shape[1] + overview_encoded.shape[1]
            model = create_model(input_dim)  # Create model with correct dimensions
            first_pass = False

        combined_features = hstack([genres_encoded, overview_encoded])
        labels = (df_chunk['vote_average'] >= 5.0).astype(int)
        # fit the model on combined features and binary labels indicating if the vote average is >= 5
        model.fit(combined_features, labels, epochs=epochs, validation_split=0.1)

    return model, genre_encoder, vectorizer
    

# Recommendation function
# Cache for movie details to avoid redundant API calls
def get_movie_details(movie_id, api_key):
    #check if moovie details cached
    if movie_id not in movie_details_cache:
        #get it from api and cache
        movie_details_cache[movie_id] = fetch_movie_details(movie_id, api_key)
    return movie_details_cache[movie_id]


def recommend_movies(user_id, model, genre_encoder, tfidf_vectorizer, db, api_key):
    global movie_details_cache
    #initialize the cache for movie details
    movie_details_cache = {}
   # initialize the scored_movies list
    scored_movies = []

    # get user watchlist from the database
    user_watchlist = get_user_watchlist(user_id, db)
    
    # generate the user's profile based on their watchlist
    user_profile = generate_user_profile(user_watchlist, genre_encoder, tfidf_vectorizer, api_key)
    
    # get additional movies for potential recommendation
    additional_movies = fetch_additional_movies(api_key, number_of_movies=250)
    
    # keep track of processed movie IDs to avoid redundancy
    processed_movie_ids = set()

    # scoere each additional movie and add results to scored_movies list
    for movie in additional_movies:
        if movie['id'] not in processed_movie_ids:
            processed_movie_ids.add(movie['id'])
            score_result = score_movies([movie], user_profile, model, genre_encoder, tfidf_vectorizer)
            scored_movies.extend(score_result)

    # Fetch and score similar movies for each movie in the users watchlist
    for movie in user_watchlist:
        similar_movies = fetch_similar_movies(movie['id'], api_key)
        for sim_movie in similar_movies:
            if sim_movie['id'] not in processed_movie_ids:
                processed_movie_ids.add(sim_movie['id'])
                sim_movie_details = get_movie_details(sim_movie['id'], api_key)
                if sim_movie_details:
                    genres = [g['name'] for g in sim_movie_details.get('genres', [])]
                    overview = sim_movie_details.get('overview', '')
                    movie_input = prepare_input(genres, overview, genre_encoder, tfidf_vectorizer)
                    predicted_rating = model.predict(movie_input)[0][0]
                    if predicted_rating > 0.45:
                        scored_movies.append((sim_movie_details['title'], predicted_rating, sim_movie['id']))
                        print(f"Added to recommendations: {sim_movie_details['title']}")
                        
    #randomize the order os score movies
    random.shuffle(scored_movies)
    # Apply watchlist filter to recommendations
    
    watchlist_ids = {movie['id'] for movie in user_watchlist}
    recommendations = [movie for movie in scored_movies if movie[2] not in watchlist_ids]
    #recommendations.sort(key=lambda x: x[1], reverse=True)  # Sort by score, higher is better
    
    
    if recommendations:
        print('Recommended Movies:')
        for  movie_id in recommendations:
            print(f"ID: {movie_id}")
    else:
        print("No movies met the recommendation threshold.")

    return recommendations



