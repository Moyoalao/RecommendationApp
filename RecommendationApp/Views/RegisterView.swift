//
//  RegisterView.swift
//  RecommendationApp
//

import SwiftUI

//Registration page
struct RegisterView: View {
    
    //Registration logic
    @StateObject var viewModel = RegisterViewModel()
    
    var body: some View {
        VStack {
            HeaderView(title: "Register", subtitle: "Binging Made Fun", background: .pink)
            
            // Registration Form
            Form {
                // Name field
                TextField("Name", text: $viewModel.name)
                    .textFieldStyle(DefaultTextFieldStyle())
                
                // Email field
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(DefaultTextFieldStyle())
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                
                // Password field
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(DefaultTextFieldStyle())
                
                // Submit button
                Button(action: viewModel.register) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Login")
                    }
                }
                .padding()
                .background(Color.pink)
                .foregroundColor(.white)
                .cornerRadius(5)
                .disabled(viewModel.isLoading)  // Disable the button when loading
                
                // Display error message if any
                if let errorMessage = viewModel.registrationError, !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding()
            
            Spacer()
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
