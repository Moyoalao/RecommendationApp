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
                viewModel.getList(userId: userId)
            }
            .navigationBarTitle("Watch List")
            .refreshable {
                viewModel.getList(userId: userId)
            }
        }
    }

    
    
    struct WatchList: View {
        var movie: myMovie
        let userId: String
        
        @EnvironmentObject var viewModel: WatchLaterViewModel
        
        @State private var showUserRating = false
        @State private var tempRating: Double?
        
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
                RatingView(userRating: $tempRating) { newRating in
                    viewModel.userMovieRatings(movieId: movie.id, userRating: newRating, userId: userId)
                    showUserRating = false
                }
            }
            
        }
    }
    
    
    struct RatingView: View {
        @Binding var userRating: Double?
        
        let onSave: (Double) -> Void
        
        var body: some View {
            
            VStack {
                Text("Rate movie").font(.headline)
                Slider(value:  Binding(get: {
                    self.userRating ?? 0
                }, set: {
                    self.userRating = $0
                    
                }), in: 0...10, step: 0.1)
                
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

