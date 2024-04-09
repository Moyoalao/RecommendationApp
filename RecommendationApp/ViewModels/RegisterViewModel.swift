//
//  RegisterModel.swift
//  RecommendationApp
//
//  Created by Musibau Alao on 03/04/2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class RegisterViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var registrationError: String? // To handle and display registration errors

    init() {}
    
    // User registration function
    func register() {
        // Validate user input
        guard validate() else {
            
            return
        }
        
        // Firebase authentication to add new user
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    // Handle and show error to the user
                    self?.registrationError = error.localizedDescription
                    return
                }
                
                guard let userID = result?.user.uid else {
                    // Handle the unexpected error case where result is nil without error
                    self?.registrationError = "Failed to obtain user ID."
                    return
                }
                
                self?.insertUserData(id: userID)
            }
        }
    }
    
    // Inserts user data into Firestore
    private func insertUserData(id: String) {
        let newUser = User(id: id, name: name, email: email, password: password, joined: Date().timeIntervalSince1970)
        let db = Firestore.firestore()
        
        db.collection("users").document(id).setData(newUser.asDictionary()) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    // Handle Firestore insertion error
                    self?.registrationError = error.localizedDescription
                }
                
            }
        }
    }
    
    // Validates the registration input
    private func validate() -> Bool {
        // Check if data fields are empty
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            registrationError = "All fields are required."
            return false
        }
        
        // Checking the email format
        guard email.contains("@") && email.contains(".") else {
            registrationError = "Please use a valid email format."
            return false
        }
        
        // Password length check
        guard password.count >= 8 else {
            registrationError = "Password must be at least 8 characters long."
            return false
        }
        
        return true
    }
}
