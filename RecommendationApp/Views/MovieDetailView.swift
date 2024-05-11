//
//  MovieDetailView.swift
//  RecommendationApp
//

import SwiftUI

//Displays the details of the movie
struct MovieDetailView: View {
    
    let movie: myMovie
    
    @EnvironmentObject var viewModel: WatchLaterViewModel
    var userId: String
    
    

    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
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
                
                //adds the movie to the users watchlist when pressed
                Button("Add To List") {
                    viewModel.addMovie(movie: movie, userId: userId)
                        
                }
                .disabled(viewModel.checkMovie(movieId: movie.id))
                .padding()
                .background( viewModel.checkMovie(movieId: movie.id) ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
          
            }
        }
        .navigationTitle("Movie Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}



// Preview Provider
struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetailView(movie: myMovie(id: 1, title: "Example Movie", overview: "This is a detailed overview of the movie, describing what it is about, its themes, and major plot points.", releaseDate: "2023-01-01", posterPath: "/pathToExampleMoviePoster.jpg", genreIds: [], ratings: 2.2), userId: "")
    }
}
