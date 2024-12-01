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
        Group {
            if viewModel.isLoggedIn {
                TabView {
                    HomeView()
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
            } else {
                LoginView(onLoginSuccess: {
                    viewModel.isLoggedIn = true
                })
            }
        }
        .onAppear {
            viewModel.checkLoginStatus()
        }
    }
}

#Preview {
    ContentView()
}
