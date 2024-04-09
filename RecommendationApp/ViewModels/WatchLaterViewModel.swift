//
//  WatchLaterViewModel.swift
//  RecommendationApp
//
//  Created by Musibau Alao on 03/04/2024.
//

import Foundation
import Firebase
import Combine


class WatchLaterViewModel: ObservableObject {
   
    private var db = Firestore.firestore()
    
    @Published var watchList: [myMovie] = []
    
    
    
}
