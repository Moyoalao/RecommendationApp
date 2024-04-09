//
//  WatchLaterView.swift
//  RecommendationApp
//
//  Created by Musibau Alao on 03/04/2024.
//

import SwiftUI

struct WatchLaterView: View {
    @EnvironmentObject var viewModel: WatchLaterViewModel
     let userId: String
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.movies, id: \.id) { movie in
                    WatchList(movie: movie)
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
                viewModel.getList(userId: userId)
            }
            .navigationBarTitle("Watch Later")
            .refreshable {
                viewModel.getList(userId: userId)
            }
        }
    }

    
    
    struct WatchList: View {
        var movie: myMovie  // Assuming Movie is your model type
        
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
                    
                    Text("Rating: \(String(format: "%.1f", movie.ratings))")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.leading, 8)
                
                
            }
        }
    }
}
