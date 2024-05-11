import numpy as np
from flask import Flask, request, jsonify
from flask.json import JSONEncoder
from TensorModel import recommend_movies, setup_transformers, train_model, initialize_firebase

# create a Flask application instance
app = Flask(__name__)

# intialize firebase connection and store the database client object
db = initialize_firebase()

# define a custom json encoder to handle numpy float32 types during json seralization
class CustomJSONEncoder(JSONEncoder):
    def default(self, obj):
        # check if the object instance is a numpy float32
        if isinstance(obj, np.float32):
            # convert numpy float32 to standard python float for JSON compatibility
            return float(obj)
            # Use the default json encoder for others
        return super().default(obj)

# set  custom json encoder for  application to handle serialzation of specific data types
app.json_encoder = CustomJSONEncoder

# initialze data transformers and train the recommendation model
genre_encoder, tfidf_vectorizer = setup_transformers()
trained_model, genre_encoder, tfidf_vectorizer = train_model('RecommendationApp/Other/movies_metadata.csv', tfidf_vectorizer, genre_encoder, epochs=5)

# route for the root of the application
@app.route('/')
def home():
    return "Recommendation Service is running!"

#route to handle POST requests for movie recommendations
@app.route('/recommend', methods=['POST'])
def recommend():
    try:
        # parse json data from the request
        data = request.json
        # gwt the user id from the request data
        user_id = data['user_id']
        # get the api key from the request data
        api_key = data['api_key']
        
        # recommend_movies function with the necessary parameters
        recommendations = recommend_movies(user_id, trained_model, genre_encoder, tfidf_vectorizer, db, api_key)
        
        #movie_ids = [movie[2] for movie in recommendations if len(movie) == 3 and isinstance(movie[2], int)]
        
        # get movie titles from the recommendations ensuring data integrity
        movie_titles = [movie[0] for movie in recommendations if len(movie) >= 1 and isinstance(movie[0], str)]

        # return the recommended movie titles as a JSON response
        return jsonify({"recommended_movie_title": movie_titles})
    except KeyError as e:#cases where required data fields are missing in the request
        return jsonify({"error": f"Missing data in request: {str(e)}"}), 400
    except Exception as e:
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500

# run the Flask application
if __name__ == '__main__':
    app.run(debug=True)

