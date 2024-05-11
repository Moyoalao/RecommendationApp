//
//  DashboardViewModel.swift
//  RecommendationApp
//


import Foundation
import Combine

// DashboardViewModel for managing UI updates and network requests
class DashboardViewModel: ObservableObject {
    
    @Published var movies: [myMovie] = []
    @Published var genres: [Int: String] = [:]
    @Published var isLoading = false
    @Published var firstLoading = false
    
    
    private var userId: String
    internal var cancellables: Set<AnyCancellable> = []
    private let apiKey = "4100576928222e78008dff8f63f4bf37"
    private var page = 1
    private let group = DispatchGroup()
    private let seasion: URLSession
    
    init(userId: String, seasion: URLSession) {
        self.userId = userId
        self.seasion = seasion
        self.getGenres()
        
    }
    

   
    // get movie genres from the TMDb API
    func getGenres() {
        let urlString = "https://api.themoviedb.org/3/genre/movie/list?api_key=\(apiKey)&language=en-US"
        guard let url = URL(string: urlString) else { return }
        self.seasion.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let genresResponse = try JSONDecoder().decode(GenreResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.genres = genresResponse.genres.reduce(into: [Int: String]()) { $0[$1.id] = $1.name }
                }
            } catch {
                print("Error decoding genres: \(error)")
            }
        }.resume()
    }
    
    // get popular movies from the TMDb API
    func getMovies() {
           let urlString = "https://api.themoviedb.org/3/movie/popular?api_key=\(apiKey)&language=en-US&page=\(page)"
           guard let url = URL(string: urlString) else { return }

        self.seasion.dataTask(with: url) { [weak self] data, response, error in
               guard let self = self, let data = data, error == nil else {
                   print("Error fetching movies: \(error!.localizedDescription)")
                   return
               }
               do {
                   let result = try JSONDecoder().decode(MovieSearch.self, from: data)
                   DispatchQueue.main.async {
                       result.results.forEach { movie in
                           var updatedMovie = movie
                           updatedMovie.genreNames = movie.genreIds.compactMap { self.genres[$0] }
                           self.movies.append(updatedMovie)
                       }
                       self.page += 1
                   }
               } catch {
                   print("Decoding error: \(error)")
               }
           }.resume()
       }
    
    
    
    // get movie recommendations based on the user ID
    func getRecommendations() {
        print("Fetching recommendations...")
        DispatchQueue.main.async {
            // Ensure firstLoading is checked and set in the main thread to prevent race conditions
            guard !self.firstLoading else { return }
            self.firstLoading = true
            self.isLoading = true
            self.movies.removeAll()
        }
        let urlString = "http://127.0.0.1:5000/recommend"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            DispatchQueue.main.async {
                // Reset loading flags if URL is invalid
                self.isLoading = false
                self.firstLoading = false
            }
            return
        }
        let requestPayload = RecommendationRequest(user_id: userId, api_key: apiKey)
        guard let postData = try? JSONEncoder().encode(requestPayload) else {
            print("Failed to encode request data")
            DispatchQueue.main.async {
                // Reset loading flags if encoding fails
                self.isLoading = false
                self.firstLoading = false
            }
            return
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 85.0
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = postData
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        self.seasion.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Network request failed: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    // Reset loading flags on failure
                    self?.isLoading = false
                    self?.firstLoading = false
                }
                return
            }

            do {
                let response = try JSONDecoder().decode(RecommendationResponse.self, from: data)
                DispatchQueue.main.async {
                    // Fetch movie details based on the titles recommended
                    self?.getRecommendedMovies(movieTitles: response.results)
                    self?.isLoading = false
                    self?.firstLoading = false
                    print("Done")
                }
            } catch {
                print("Decoding error: \(error)")
                DispatchQueue.main.async {
                    // Reset loading flags on decoding error
                    self?.isLoading = false
                    self?.firstLoading = false
                    self?.getMovies()
                }
            }
        }.resume()
    }



    // get details for recommended movies by their titles
    func getRecommendedMovies(movieTitles: [String]) {
           self.movies.removeAll()
           for title in movieTitles {
               let queryTitle = title.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
               let urlString = "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&language=en-US&query=\(queryTitle)"
               guard let url = URL(string: urlString) else {
                   print("Invalid URL for movie title \(title)")
                   return
               }

               self.seasion.dataTask(with: url) { [weak self] data, response, error in
                   guard let self = self, let data = data, error == nil else {
                       print("Error fetching movie details for title \(title): \(error?.localizedDescription ?? "unknown error")")
                       return
                   }

                   do {
                       let searchResult = try JSONDecoder().decode(MovieSearch.self, from: data)
                       DispatchQueue.main.async {
                           if let movieDetail = searchResult.results.first {
                               var updatedMovie = movieDetail
                               updatedMovie.genreNames = movieDetail.genreIds.compactMap { self.genres[$0] }
                               self.movies.append(updatedMovie)
                           }
                       }
                   } catch {
                       print("Decoding error for movie title \(title): \(error)")
                   }
               }.resume()
           }
       }
}



// Codable structures for handling API responses
struct Genre: Codable, Identifiable {
    let id: Int
    let name: String
}

struct GenreResponse: Codable {
    let genres: [Genre]
}

struct MovieSearch: Codable {
    let results: [myMovie]
}
