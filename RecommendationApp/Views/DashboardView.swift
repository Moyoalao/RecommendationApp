//
//  DashboardView.swift
//  RecommendationApp
//
//  Created by Musibau Alao on 02/04/2024.
//

import SwiftUI

struct DashboardView: View {
    
    @StateObject var viewModel = DashboardViewModel()
    private let userID: String
    
    init(userID: String) {
        self.userID = userID
    }

    var body: some View {
        
        NavigationView {
            List {// Use the movies array directly
                ForEach(viewModel.movies, id: \.id) {movie in // displays the movies in the array in a row
                    NavigationLink(destination: MovieDetailView(movie: movie)) {// link to the details view of the movie
                        MovieRow(movie: movie)
                        
                    }
                    
                }
                //loads more movies if any
                if !viewModel.movies.isEmpty {
                    Button("More") {
                        viewModel.getMovies()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
               
                
            }
            .navigationBarTitle("Movies")
        }
        
    }
    
}

struct MovieRow: View {
    var movie: myMovie
    
    var body: some View {
        HStack {
            // Display movie poster and details
            if let posterURL = URL(string: "https://image.tmdb.org/t/p/w500\(movie.posterPath)") {
                AsyncImage(url: posterURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable() // Display the loaded image.
                    case .failure(_):
                        Image(systemName: "photo") // Placeholder for an error.
                            .accessibilityLabel("Error loading image")
                    case .empty:
                        ProgressView() // Loading state.
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
                if let genres = movie.genreNames , !genres.isEmpty {
                    Text(genres.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.green)
                } else {
                    Text("No Genres")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text("Rating: \(String(format: "%.1f", movie.ratings))")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .padding(.leading, 8)
            
            
        }
       
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(userID: " ")
    }
}
