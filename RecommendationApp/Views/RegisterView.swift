//
//  RegisterView.swift
//  RecommendationApp
//
//  Created by Musibau Alao on 03/04/2024.
//

import SwiftUI

struct RegisterView: View {
    
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
                    Text("Submit").foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.pink)
                .cornerRadius(8)
                
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
