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
            
            List(viewModel.filteredMovies) { movie in
                NavigationLink(destination: MovieDetailView(movie: movie)){
                    HStack {
                        //display movie title and date of release
                        if let posterURL = URL(string: "https://image.tmdb.org/t/p/w500\(movie.posterPath)") {
                            AsyncImage(url: posterURL) { phase in
                                if let image = phase.image {
                                    image.resizable() // Display the loaded image.
                                } else if phase.error != nil {
                                    Image(systemName: "photo") // Placeholder for an error.
                                        .accessibilityLabel("Error loading image")
                                } else {
                                    ProgressView() // Loading state.
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
                        }
                    }
                }
            }
            .searchable(text: $viewModel.searchText)
            .navigationTitle("Dashboard")
            .onAppear {
                viewModel.getMovies()
                print("Number of movies: \(viewModel.movies.count)")
            }
        }
    }
}


struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(userID: " ")
    }
}
