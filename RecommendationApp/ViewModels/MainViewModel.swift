//
//  MainViewModel.swift
//  RecommendationApp
//

import Foundation
import FirebaseAuth

//manges authentication state with firebase
class MainViewModel: ObservableObject {
    
    @Published var currentID: String = ""
    
    private var handler: AuthStateDidChangeListenerHandle?
    // Initializes the view model, setting up the Firebase authentication state listener.
    init(){
        // Adds a listener for the authentication state change events from FirebaseAuth.
        self.handler = Auth.auth().addStateDidChangeListener{[weak self] _, user in
            self?.currentID = user?.uid ?? ""
        }
    }
    
    //check if the user is signed in
    public var isSignedIn: Bool{
        return Auth.auth().currentUser != nil
    }
    deinit {
        if let handler = handler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }
    
}
