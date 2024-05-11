//
//  ProfileViewModel.swift
//  RecommendationApp
//


import Foundation
import FirebaseFirestore
import FirebaseAuth


class ProfileViewModel: ObservableObject {
    
    @Published var user: User? = nil  // Holds the current users information
    
    // Initializes the ViewModel
    init() {}
    
    // Fetches the current users information from Firestore
    func getUser() {
        guard let userID = Auth.auth().currentUser?.uid else {
            // No user is signed in
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(userID).getDocument { [weak self] snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                // Handle errors or absence of data appropriately
                print("Error fetching user data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Updates the published `user` property on the main thread
            DispatchQueue.main.async {
                self?.user = User.fromFirestore(data)
                
            }
        }
    }
    
    
    
    // Signs out the current user
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
        } catch {
            // Handle sign out error
            print("Error signing out: \(error)")
        }
    }
}


extension User {
    static func fromFirestore(_ data: [String: Any]) -> User {
        return User (
            id: data["id"] as? String ?? "",
            name: data["name"] as? String ?? "",
            email: data["email"] as? String ?? "",
            password: data["password"] as? String ?? "",
            joined: data["joined"] as? TimeInterval ?? 0
        )
    }
}
