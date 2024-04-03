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
            List(viewModel.movies) { movie in
                HStack {
                    if let posterURL = movie.posterURL, let imageData = try? Data(contentsOf: posterURL), let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
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
