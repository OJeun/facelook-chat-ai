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
                // Pass userID to HomeView
                HomeView(userID: viewModel.userID)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }

                ProfileView()
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
            LoginView(onLoginSuccess: { userID in
                print("Login successful with userID: \(userID)")
                viewModel.isLoggedIn = true
                viewModel.userID = userID
            })
        }
    }
}

#Preview {
    ContentView()
}
