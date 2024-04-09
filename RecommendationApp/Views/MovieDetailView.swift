//
//  MovieDetailView.swift
//  RecommendationApp
//
//  Created by Musibau Alao on 03/04/2024.
//

import SwiftUI

struct MovieDetailView: View {
    let movie: myMovie
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if let posterURL = URL(string: "https://image.tmdb.org/t/p/w500\(movie.posterPath)") {
                    AsyncImage(url: posterURL) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    .cornerRadius(8)
                    .shadow(radius: 5)
                    .padding()
                }
                
                Text(movie.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding([.leading, .trailing, .top])
                
                Text("Release Date: \(movie.releaseDate)")
                    .font(.headline)
                    .padding([.leading, .trailing])
                Text("Rating: \(String(format: "%.1f", movie.ratings))")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding([.leading, .trailing])
    
                Text(movie.overview)
                    .font(.body)
                    .padding()
            }
        }
        .navigationTitle("Movie Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Define a simple Movie model for this example
struct Movie: Identifiable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String
    let releaseDate: String
}

// Preview Provider
struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetailView(movie: myMovie(id: 1, title: "Example Movie", overview: "This is a detailed overview of the movie, describing what it is about, its themes, and major plot points.", releaseDate: "2023-01-01", posterPath: "/pathToExampleMoviePoster.jpg", genreIds: [], ratings: 2.2))
    }
}
