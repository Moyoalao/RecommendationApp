//
//  WatchLaterViewModel.swift
//  RecommendationApp
//
//  Created by Musibau Alao on 03/04/2024.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

class WatchLaterViewModel: ObservableObject {
   
    private var db = Firestore.firestore()
    
    @Published var movies: [myMovie] = []
    @Published var watchList: Set<Int> = []
    @Published var errorMessage: String? // For UI error reporting
    
    // Fetch the watch list IDs only, useful for checks without loading full movie data
    func checkWatchList(userId: String) {
        Firestore.firestore().collection("watchList").document(userId).collection("movies").getDocuments { (snapshot, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch watchlist: \(error.localizedDescription)"
                }
                return
            }
            guard let documents = snapshot?.documents else {
                DispatchQueue.main.async {
                    self.errorMessage = "No Documents in the watchlist"
                }
                return
            }
            DispatchQueue.main.async {
                self.watchList = Set(documents.compactMap { $0["id"] as? Int })
            }
        }
    }
    
    // Check if a movie is already in the watch list
    func checkMovie(movieId: Int) -> Bool {
        return watchList.contains(movieId)
    }
    
    // Add a movie to the watch list in Firestore and locally
    func addMovie(movie: myMovie, userId: String) {
        guard !watchList.contains(movie.id) else {
            print("Movie already in watch list.")
            return
        }
        
        let ref = db.collection("watchList").document(userId).collection("movies").document("\(movie.id)")
        ref.setData(movie.dictionary) { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error adding movie to Firestore: \(error.localizedDescription)"
                }
            } else {
                DispatchQueue.main.async {
                    self.movies.append(movie)
                    self.watchList.insert(movie.id)
                    print("Movie Added")
                }
            }
        }
    }
    
    
    func removeMovie(movieId: Int, userId: String) {
        let ref = db.collection("watchList").document(userId).collection("movies").document("\(movieId)")
        
        //remove from firestore
        ref.delete() { error in
            if let error = error {
                print("Error removing movie from Firestore: \(error.localizedDescription)")
            }else {
                //Romves from local
                DispatchQueue.main.async {
                    self.movies.removeAll { $0.id == movieId}
                    self.watchList.remove(movieId)
                    print("Move Removed")
                }
            }
            
        }
    }
    
    // Get the list of movies from Firestore and ensure no duplicates are added
    func getList(userId: String) {
        db.collection("watchList").document(userId).collection("movies").addSnapshotListener { (snapshot, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error retrieving watch list: \(error.localizedDescription)"
                }
                return
            }
            guard let documents = snapshot?.documents, !documents.isEmpty else {
                DispatchQueue.main.async {
                    self.errorMessage = "No document in watchlist"
                }
                return
            }
            DispatchQueue.main.async {
                self.movies = documents.compactMap { doc in
                    do {
                        let movie = try doc.data(as: myMovie.self)
                        return movie
                    } catch {
                        self.errorMessage = "Error decoding movie from Firestore document: \(doc.documentID), error: \(error)"
                        return nil
                    }
                }
                print("Updated movies from Firestore: \(self.movies.count) movies fetched.")
            }
        }
    }
}
