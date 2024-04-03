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
    let id: Int
    
    /// The title of the movie.
    let title: String
    
    /// Overview of the movie.
    let overview: String
    
    /// The release date of the movie.
    let releaseDate: String
    
    /// The path to the movie poster image.
    let posterPath: String
    
    /// Computed property to get the full URL of the movie poster.
    var posterURL: URL? {
        URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case releaseDate = "release_date"
        case posterPath = "poster_path"
    }
}
