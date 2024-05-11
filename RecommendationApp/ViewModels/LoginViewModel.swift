//
//  LoginViewModel.swift
//  RecommendationApp
//


import Foundation
import FirebaseAuth

/// ViewModel for login functionality.
class LoginViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var error = ""
    @Published var isLoading = false
    
    
    
    init() {}
    
    /// Handles the login process with Firebase Authentication.
    func login() {
        guard validate() else { return }
        
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    // Handling Firebase authentication error
                    self?.error = error.localizedDescription
                } else {
                    // Successful authentication
                    self?.error = "" // Resetting error message
                    print("Firebase Auth Error: \(String(describing: error))")
                }
                self?.isLoading = false
            }
        }
    }
    
    //Validates format of email
    private func emailCheck (_ email: String) -> Bool {
        let check = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", check).evaluate(with: email)
    }
    //Validate the password fromat
    private func passwordCheck(_ password: String) -> Bool {
            let check = "^(?=.*[a-z])(?=.*[A-Z])(?=.*[@$!%*?&]).{8,}$" // Ensure password is 8+ characters long
            if !NSPredicate(format: "SELF MATCHES %@", check).evaluate(with: password) {
                error = "Password must include at least one lowercase letter, one uppercase letter, one special character, and be at least 8 characters long."
                return false
            }
            return true
        }

    
    /// Validates user input.
    internal func validate() -> Bool {
        error = "" // Resets error
        
        // Checking if email and password fields are not empty
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            error = "Please fill in all fields."
            return false
        }
        //Rretun true when both validations are succesful
        return emailCheck(email) && passwordCheck(password)
    }
}

