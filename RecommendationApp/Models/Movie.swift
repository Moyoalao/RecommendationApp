//
//  Movie.swift
//  RecommendationApp
//
//  Created by Musibau Alao on 02/04/2024.
//

import Foundation

/// Represents a movie with its associated metadata from TMDb API.
struct myMovie: Codable, Hashable, Identifiable {
    /// The unique identifier for the movie.
    var id: Int
    
    /// The title of the movie.
    var title: String
    
    /// Overview of the movie.
    var overview: String
    
    /// The release date of the movie.
    var releaseDate: String
    
    /// The path to the movie poster image.
    var posterPath: String
    
    var genreIds: [Int]
    
    var genreNames: [String]? 
    
    var ratings: Double
    
    /// Computed property to get the full URL of the movie poster.
    var posterURL: URL? {
        URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }
    
    struct Genre: Codable, Hashable, Identifiable {
        let id: Int
        
        let name: String
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case releaseDate = "release_date"
        case posterPath = "poster_path"
        case genreIds = "genre_ids"
        case ratings = "vote_average"
    }
    
}
