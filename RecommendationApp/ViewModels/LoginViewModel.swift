//
//  LoginViewModel.swift
//  RecommendationApp
//
//  Created by Musibau Alao on 03/04/2024.
//

import Foundation
import FirebaseAuth

/// ViewModel for login functionality.
class LoginViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var error = ""
    
    init() {}
    
    /// Handles the login process with Firebase Authentication.
    func login() {
        guard validate() else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    // Handling Firebase authentication error
                    self?.error = error.localizedDescription
                } else {
                    // Successful authentication
                    self?.error = "" // Resetting error message
                }
            }
        }
    }
    
    /// Validates user input.
    private func validate() -> Bool {
        error = "" // Resets error
        
        // Checking if email and password fields are not empty
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            error = "Please fill in all fields."
            return false
        }
        
        // Checking the email format
        guard email.contains("@") && email.contains(".") else {
            error = "Please use a valid email format."
            return false
        }
        
        // Input is valid
        return true
    }
}

