//
//  DashboardViewModel.swift
//  RecommendationApp
//
//  Created by Musibau Alao on 03/04/2024.
//

import Foundation
import Combine

class DashboardViewModel: ObservableObject {
    
    //trigger UI updates
    @Published var movies: [myMovie] = []//fetched movies
    @Published var genres: [Int: String] = [:]
    
    private var cancellables: Set<AnyCancellable> = []
    private let apiKey = "4100576928222e78008dff8f63f4bf37"
    private var page = 1
    
    init() {
        getGenres()
        getMovies()
    }
    
    

    // Method for connecting to the TMDb API and fetching popular movies
    func getMovies() {
        let urlString = "https://api.themoviedb.org/3/movie/popular?api_key=\(apiKey)&language=en-US&page=\(page)"
        guard let url = URL(string: urlString) else {
            return }
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                    guard let data = data, error == nil else { return }
                    
                    do {
                        let result = try JSONDecoder().decode(MovieSearch.self, from: data)
                        DispatchQueue.main.async {
                            result.results.forEach { movie in
                                var updateMovie = movie
                                updateMovie.genreNames = movie.genreIds.compactMap { self?.genres[$0] }
                                self?.movies.append(updateMovie)
                            }
                            self?.page += 1

                        }
                    } catch {
                        print("Decoding error: \(error)")
                    }
        }.resume()
    }
    
    func getGenres() {
         let urlString = "https://api.themoviedb.org/3/genre/movie/list?api_key=\(apiKey)&language=en-US"
        guard let url = URL(string: urlString) else {return}
        URLSession.shared.dataTask(with: url){[weak self] data, response, error in
            guard let data = data, error == nil else { return}
            
            do{
                let genresResponse = try JSONDecoder().decode(GenreResponse.self, from: data )
                DispatchQueue.main.async {
                    self?.genres = genresResponse.genres.reduce(into: [Int: String]()) { $0[$1.id] = $1.name}
                }
            }catch {
                print("Error Decoding Genres: \(error)")
            }
        }.resume()
        
    }
    
    
}

struct Genre: Codable, Identifiable {
    let id: Int
    let name: String
}

struct GenreResponse: Codable {
    let genres: [Genre]
}

struct MovieSearch: Decodable {
    let results: [myMovie]
}


