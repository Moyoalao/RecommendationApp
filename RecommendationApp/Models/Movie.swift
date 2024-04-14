//
//  Movie.swift
//  RecommendationApp
//
//  Created by Musibau Alao on 02/04/2024.
//

import Foundation

// Represents a movie with its associated metadata from TMDb API.
struct myMovie: Codable, Hashable, Identifiable {
    // The unique identifier for the movie.
    var id: Int
    
    // The title of the movie.
    var title: String
    
    // Overview of the movie.
    var overview: String
    
    // The release date of the movie.
    var releaseDate: String
    
    // The path to the movie poster image.
    var posterPath: String
    
    // Genre IDs associated with the movie.
    var genreIds: [Int]
    
    var genreNames: [String]? 
    
    // Average user rating of the movie.
    var ratings: Double
    
    // Computed property to get the full URL of the movie poster.
    var posterURL: URL? {
        URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }
    
    struct Genre: Codable, Hashable, Identifiable {
        let id: Int
        
        let name: String
    }
    
    // Specifies the keys used to encode and decode data
    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case releaseDate = "release_date"
        case posterPath = "poster_path"
        case genreIds = "genre_ids"
        case ratings = "vote_average"
    }
    
}

//  a dictionary representation of movie data , for interfacing with non-Swift systems and debugging
extension myMovie {
    var dictionary: [String: Any] {
        var dict = [String: Any]()
        dict["id"] = id
        dict["title"] = title
        dict["overview"] = overview
        dict["release_date"] = releaseDate
        dict["poster_path"] = posterPath
        dict["genre_ids"] = genreIds
        dict["vote_average"] = ratings
        
        // Optional property: Include only if it's not nil
        if let genreNames = genreNames {
            dict["genreNames"] = genreNames
        }

        return dict
    }
}
