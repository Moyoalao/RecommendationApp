//
//  LoginView.swift
//  RecommendationApp
//
//  Created by Musibau Alao on 03/04/2024.
//

import SwiftUI

struct LoginView: View {
    
    @StateObject var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                // Header
                HeaderView(title: "Login", subtitle: "Binging to the Max", background: .red)
                
                // Login form
                Form {
                    // Displaying error if any
                    if !viewModel.error.isEmpty {
                        Text(viewModel.error).foregroundColor(.red)
                    }
                    
                    // Email field
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(5)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    
                    // Password field
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    // Login button
                    Button("Login", action: viewModel.login)
                        .padding(10)
                        .background(Color.pink)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                
                // Link to create account
                VStack {
                    Text("New?")
                    NavigationLink("Create Account", destination: RegisterView())
                }
                .padding(30)
                
                Spacer()
            }
        }
    }
}

// SwiftUI's convention for previews
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
