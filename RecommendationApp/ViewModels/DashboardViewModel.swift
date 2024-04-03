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
    @Published var filteredMovies: [myMovie] = []//filtered movies
    @Published var searchText = "" //
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        //combine pipline to filter movies
        $searchText
            .removeDuplicates()
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink(receiveValue: { [weak self] searchText in
                if searchText.isEmpty {
                    self?.getMovies()
                }else {
                    self?.filterMovies(searchText: searchText)
                }
            })
            .store(in: &cancellables)
    }
    
    // Method for connecting to the TMDb API and fetching popular movies
    func getMovies() {
        let apiKey = "4100576928222e78008dff8f63f4bf37"
        let urlString = "https://api.themoviedb.org/3/movie/popular?api_key=\(apiKey)&language=en-US&page=1"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                    guard let data = data, error == nil else { return }
                    
                    do {
                        let result = try JSONDecoder().decode(MovieSearch.self, from: data)
                        DispatchQueue.main.async {
                            self?.movies = result.results
                            self?.filteredMovies = result.results
                        }
                    } catch {
                        print("Decoding error: \(error)")
                    }
        }.resume()
    }
    
    func searchMovies(searchText: String) {
        let apiKey = "4100576928222e78008dff8f63f4bf37"
        guard let query = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {return}
        let searchURLString = "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&query=\(query)"
        
        guard let url = URL(string: searchURLString) else {return}
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {return}
            
            do {
                let result = try JSONDecoder().decode(MovieSearch.self, from: data)
                DispatchQueue.main.async {
                    self?.movies = result.results
                    self?.filteredMovies = result.results
                }
            }catch {
                print("Decoding error: \(error)")//debugging
            }
        }.resume()
    }
    
    private func filterMovies(searchText: String) {
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmedSearchText.isEmpty {
            filteredMovies = movies // diaplay movies when search empty
        }else {
            filteredMovies = movies.filter {$0.title.lowercased().contains(trimmedSearchText)}// display filtered search
        }
        //debugging
        print ("search Text: \(searchText)")
        print("Filtered Movies Count: \(filteredMovies.count)")
    }
    
}

struct MovieSearch: Decodable {
    let results: [myMovie]
}


