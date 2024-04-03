//
//  User.swift
//  RecommendationApp
//
//  Created by Musibau Alao on 02/04/2024.
//

import Foundation

/// Represents a user with identifiable information.
struct User: Codable {
    /// The unique identifier for the user.
    let id: String
    
    /// The name of the user.
    let name: String
    
    /// The email address of the user.
    let email: String
    
    /// The timestamp of when the user joined.
    /// Measured in seconds since 1970 (also known as Unix time).
    let joined: TimeInterval
}
