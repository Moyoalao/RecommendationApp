//
//  DashboardView.swift
//  RecommendationApp
//

import SwiftUI

//Displays the movies to the user
struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel
    
    private let userID: String
    
    
    //initialize the view for the user
    init(userID: String) {
        self.userID = userID
        _viewModel = StateObject(wrappedValue: DashboardViewModel(userId: userID, seasion: URLSession.shared))
    }

    var body: some View {
            NavigationView {
                VStack{
                    List {
                        content
                    }
                    .navigationBarTitle("Movies Dashboard")
                    
                    loadMoreButton
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    
                }
                
                .onAppear {
                    //Gets the recommendations
                    if viewModel.movies.isEmpty {
                        viewModel.getRecommendations()
                    }
                }
            }
        }
    
    //Handle the state of conent loading , empty , movelist
    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView("Fetching recommendations...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.scale.combined(with: .opacity))
                .animation(.easeInOut(duration: 1.0), value: viewModel.isLoading)
        } else if viewModel.movies.isEmpty{
            Text("No recommendations available.")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            movieList
        }
    }

    //Builds list of movies using MovieRow
    private var movieList: some View {
        ForEach(viewModel.movies, id: \.uuid) { movie in
            NavigationLink(destination: MovieDetailView(movie: movie, userId: userID)) {
                MovieRow(movie: movie)
            }
        }
    }
    
    //Load Recommendations
    private var loadMoreButton: some View {
        Button("Load Recommendations") {
            viewModel.movies.removeAll()
            viewModel.getRecommendations()
        }
        .frame(maxWidth: .infinity)
        .padding()
     
    }
}


struct MovieRow: View {
    var movie: myMovie // Use myMovie model
    
    var body: some View {
        HStack {
            moviePoster
            movieDetails
        }
    }
    
    //Loads and displays movie poster
    private var moviePoster: some View {
        AsyncImage(url: movie.posterURL) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFit()
            case .failure:
                Image(systemName: "photo").accessibilityLabel("Error loading image")
            case .empty:
                ProgressView()
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: 100, height: 150)
        .cornerRadius(8)
    }
    
    //Displays Details - title , release date , genres and rating
    private var movieDetails: some View {
        VStack(alignment: .leading) {
            Text(movie.title)
                .foregroundColor(.primary)
                .font(.headline)
            Text(movie.releaseDate)
                .foregroundColor(.secondary)
                .font(.subheadline)
            genreText
            Text("Rating: \(String(format: "%.1f", movie.ratings))")
                .font(.caption)
                .foregroundColor(.blue)
        }
        .padding(.leading, 8)
    }
    //Concatenates genres into string seprated by commas
    private var genreText: some View {
        Text(movie.genreNames?.joined(separator: ", ") ?? "No Genres")
            .font(.caption)
            .foregroundColor(movie.genreNames?.isEmpty ?? true ? .gray : .green)
    }
}


