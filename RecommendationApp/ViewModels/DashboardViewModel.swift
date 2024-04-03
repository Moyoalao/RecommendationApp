//
//  DashboardViewModel.swift
//  RecommendationApp
//
//  Created by Musibau Alao on 03/04/2024.
//

import Foundation

class DashboardViewModel: ObservableObject {
    
    @Published var movies: [myMovie] = []
    
    init() {
        getMovies()
    }
    
    // Method for connecting to the TMDb API and fetching movies
    func getMovies() {
        let apiKey = "4100576928222e78008dff8f63f4bf37"
        let urlString = "https://api.themoviedb.org/3/movie/popular?api_key=\(apiKey)&language=en-US&page=1"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Networking error: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                if let data = data {
                    do {
                        let result = try JSONDecoder().decode(MovieSearch.self, from: data)
                        self?.movies = result.results
                    } catch {
                        print("Decoding error: \(error)")
                    }
                }
            }
        }.resume()
    }
}

// Assuming TMDb's movie list JSON structure looks something like this:
struct MovieSearch: Decodable {
    let results: [myMovie]
}

// Update this Movie struct based on TMDb's actual movie data structure.
struct Movie: Decodable, Identifiable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String
    let releaseDate: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
    }
}
