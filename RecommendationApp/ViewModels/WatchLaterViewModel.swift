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
    
    func addMovie(movie: myMovie, userId: String) {
        
        
        let ref =  db.collection("watchList").document(userId).collection("movies").document("\(movie.id)")
        
        ref.setData(movie.dictionary) { error in
            if let error = error {
                print("Error adding movie to Firestore: \(error.localizedDescription)")
            }else {
                print("Movie Added")
            }
        }
        
    }
    
    
    func getList(userId: String) {
        
        db.collection("watchList").document(userId).collection("movies").addSnapshotListener { (snapshot, error) in
            
            if let error = error {
                print("Error retrieving watch list: \(error.localizedDescription)")
                return
            }
            guard let documents = snapshot?.documents else {
                print("No doccument in watchlist")
                return
            }
            
            self.watchList = documents.compactMap { doc in
                 try? doc.data(as: myMovie.self)
            }
            
        }
        
    }
    
    
}
