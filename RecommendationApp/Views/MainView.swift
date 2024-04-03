//
//  MainView.swift
//  RecommendationApp
//
//  Created by Musibau Alao on 02/04/2024.
//

import SwiftUI

struct MainView: View {
    
    @StateObject var viewModel = MainViewModel()
    
    var body: some View {
        // Checks if the user is signed in and if the currentID is not empty to display the main content
        if viewModel.isSignedIn, !viewModel.currentID.isEmpty {
            mainTabView
        }else{
            // View shown to users who are not logged in.
            LoginView()
        }
    }
    
    private var mainTabView: some View {
        TabView{
            dashboardTab
            profileTab
        }
    }
    
    private var dashboardTab: some View {
        DashboardView(userID: viewModel.currentID)
            .tabItem {
                Label("Home", systemImage: "house")
            }
    }
    
    private var profileTab: some View {
        ProfileView()
            .tabItem {
                Label("Profile", systemImage: "person.circle")
            }
    }
    
    
}

// Preview provider for SwiftUI previews in Xcode.
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
