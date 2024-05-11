//
//  MainView.swift
//  RecommendationApp
//

import SwiftUI

//Main View
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
    //Tabs for the sak of navigation
    private var mainTabView: some View {
        TabView{
            dashboardTab
            watchLaterTab
            profileTab
        }
    }
    //Dashboard where the users recommendatons would be loaded
    private var dashboardTab: some View {
        DashboardView(userID: viewModel.currentID)
            .tabItem {
                Label("Home", systemImage: "house")
            }
    }
    //Displays the users details
    private var profileTab: some View {
        ProfileView()
            .tabItem {
                Label("Profile", systemImage: "person.circle")
            }
    }
    
    //where movies the user added to their list is shown
    private var watchLaterTab: some View {
        WatchLaterView(userId: viewModel.currentID)
            .tabItem {
                Label("WatchList", systemImage: "list.bullet.rectangle.portrait.fill")
            }
    }
    
}

// Preview provider for SwiftUI previews in Xcode.
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
