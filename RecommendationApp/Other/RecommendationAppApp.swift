//
//  RecommendationAppApp.swift
//  RecommendationApp
//
//  Created by Musibau Alao on 02/04/2024.
//

import SwiftUI
import FirebaseCore

@main
struct RecommendationAppApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
