//
//  ContentView.swift
//  iOS-Project
//
//  Created by Aric Or on 2024-11-01.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewViewModel()

    var body: some View {
        if viewModel.isLoggedIn {
            TabView {
                HomeView(userID: viewModel.userID, userName: viewModel.userName)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }

                ProfileView(isLoggedIn: $viewModel.isLoggedIn)
                    .tabItem {
                        Label("Profile", systemImage: "person.circle")
                    }

                LeaderboardView()
                    .tabItem {
                        Label("Leaderboard", systemImage: "chart.bar")
                    }
            }
            .onAppear {
                viewModel.checkLoginStatus()
            }
        } else {
            NavigationView {
                LoginView(onLoginSuccess: { userID, userName in
                    print("Login successful with userID: \(userID), userName: \(userName)")
                    viewModel.isLoggedIn = true
                    viewModel.userID = userID
                    viewModel.userName = userName
                    UserDefaults.standard.set(userID, forKey: "userID")
                    UserDefaults.standard.set(userName, forKey: "userName")
                })
            }
        }
    }
}

#Preview {
    ContentView()
}
