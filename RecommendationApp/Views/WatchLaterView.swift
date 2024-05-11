//
//  WatchLaterView.swift
//  RecommendationApp
//

import SwiftUI

//Displaying list of movies on the users firestore watchlist
struct WatchLaterView: View {
    @EnvironmentObject var viewModel: WatchLaterViewModel
     let userId: String
    
   
    var body: some View {
        NavigationView {
            List {
                //gos through the movies and creates rows
                ForEach(viewModel.movies, id: \.self) { movie in
                    WatchList(movie: movie, userId: userId)
                        .swipeActions {
                            Button(role: .destructive) {
                                viewModel.removeMovie(movieId: movie.id, userId: userId)
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                }
            }
            .onAppear {
                //gets the user watchlist
                viewModel.getList(userId: userId)
            }
            .navigationBarTitle("Watch List")
            .refreshable {
                viewModel.getList(userId: userId)
            }
        }
    }

    
    //View for movie on the list
    struct WatchList: View {
        var movie: myMovie
        let userId: String
        
        @EnvironmentObject var viewModel: WatchLaterViewModel
        
        @State private var showUserRating = false
        @State private var tempRating: Double?
        
        var body: some View {
            HStack {
                // Display movie poster and details
                if let posterURL = URL(string: "https://image.tmdb.org/t/p/w500\(movie.posterPath ?? "no poster")") {
                    AsyncImage(url: posterURL) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable()
                        case .failure(_):
                            Image(systemName: "photo")
                                .accessibilityLabel("Error loading image")
                        case .empty:
                            ProgressView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 100, height: 150)
                    .cornerRadius(8)
                }
                
                VStack(alignment: .leading) {
                    Text(movie.title)
                        .foregroundColor(.primary)
                        .font(.headline)
                    Text(movie.releaseDate)
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                    
                    Text("Rating: \(String(format: "%.1f", movie.ratings))")
                        .font(.caption)
                        .foregroundColor(.blue)
                    if let userRating = movie.userRating {
                        Text("User Rating: \(String(format: "%.1f", userRating))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Button("Rate") {
                        tempRating = movie.userRating
                        showUserRating = true
                    }
                    .padding(5)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(5)
                    
                }
                .padding(.leading, 8)
            
            }
            .sheet(isPresented: $showUserRating) {
                //Displays rating view to allow user to rate movies
                RatingView(userRating: $tempRating, movie: movie) { newRating in
                    viewModel.userMovieRatings(movieId: movie.id, userRating: newRating, userId: userId)
                    showUserRating = false
                }
            }
            
        }
    }
    
    //Rating View
    struct RatingView: View {
        @Binding var userRating: Double?
        var movie: myMovie
        
        let onSave: (Double) -> Void
        
        var body: some View {
            
            VStack {
                Text("Rate movie").font(.headline)
                Slider(value:  Binding(get: {
                    self.userRating ?? 0
                }, set: {
                    self.userRating = $0
                    
                }), in: 0...10, step: 0.1)
                
                if let posterURL = URL(string: "https://image.tmdb.org/t/p/w500\(movie.posterPath ?? "no poster")") {
                    AsyncImage(url: posterURL) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    .cornerRadius(8)
                    .shadow(radius: 5)
                    .padding()
                }else {
                    Image(systemName: "photo").resizable().scaledToFit()
                }
                
                Text(movie.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(String(format: "%.1f", self.userRating ?? 0)).font(.subheadline)
                Button("Save Rating") {
                    if let userRating = self.userRating {
                        onSave(userRating)
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
        }
    }
    
    
}

