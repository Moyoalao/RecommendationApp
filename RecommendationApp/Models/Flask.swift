//
//  FLaskRequest.swift
//  RecommendationApp
//

import Foundation

// Request
struct RecommendationRequest: Codable {
    let user_id: String
    let api_key: String
}

//Response
struct RecommendationResponse: Codable {
    let results: [String]
    
    
    enum CodingKeys: String, CodingKey {
           case results = "recommended_movie_title"
       }

}
