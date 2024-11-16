//
//  ContentView.swift
//  iOS-Project
//
//  Created by Aric Or on 2024-11-01.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
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
    }
}

#Preview {
    ContentView()
}
