//
//  ProfileView.swift
//  RecommendationApp
//

import SwiftUI

//Displays the users details
struct ProfileView: View {
    //getting and handling user data
    @StateObject var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if let user = viewModel.user {
                    Image(systemName: "person.circle").resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.blue)
                        .frame(width: 100, height: 100)
                        .padding()
                    
                    // Display user info
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Name:").bold()
                            Text(user.name)
                        }
                        HStack {
                            Text("Email:").bold()
                            Text(user.email)
                        }
                        HStack {
                            Text("Since:").bold()
                            Text("\(Date(timeIntervalSince1970: user.joined).formatted(date: .abbreviated, time: .shortened))")
                        }
                        
                        
                        HStack {
                            Text("For Your Inof:").bold()
                            Text("To improve recommendations make sure to add movies to your watclist and secondly make sure that you rate them ")
                        }
                    }
                    .padding()
                    
                    // Sign user out
                    Button("Sign Out") {
                        viewModel.signOut()
                    }
                    .tint(.red)
                    .padding()
                } else {
                    Text("Loading Profile...")
                }
            }
            .navigationTitle("Profile")
        }
        .onAppear { viewModel.getUser() }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
