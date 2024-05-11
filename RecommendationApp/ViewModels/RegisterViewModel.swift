//
//  RegisterModel.swift
//  RecommendationApp
//


import Foundation
import FirebaseAuth
import FirebaseFirestore

class RegisterViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var registrationError: String?
    @Published var isLoading = false

    init() {}
    
    // User registration function
    func register() {
        // Validate user input
        guard validate() else {return}
        isLoading = true
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
            self?.isLoading = false
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
    //Validates format of email
    private func emailCheck (_ email: String) -> Bool {
        let check = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", check).evaluate(with: email)
    }
    //Validate the password fromat
    private func passwordCheck(_ password: String) -> Bool {
            let check = "^(?=.*[a-z])(?=.*[A-Z])(?=.*[@$!%*?&]).{8,}$"
            if !NSPredicate(format: "SELF MATCHES %@", check).evaluate(with: password) {
                registrationError = "Password must include at least one lowercase letter, one uppercase letter, one special character, and be at least 8 characters long."
                return false
            }
            return true
        }

    
    // Validates the registration input
    internal func validate() -> Bool {
        registrationError = nil
        // Check if data fields are empty
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            registrationError = "All fields are required."
            return false
        }
        //Rretun true when both validations are succesful
        return emailCheck(email)&&passwordCheck(password)
    }
}
