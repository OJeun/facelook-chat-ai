//
//  LeaderboardView.swift
//  iOS-Project
//
//  Created by Aric Or on 2024-11-01.
//

import SwiftUI

struct LeaderboardView: View {
    @StateObject private var viewModel = LeaderboardViewViewModel()

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List(viewModel.users.indices, id: \.self) { index in
                        let user = viewModel.users[index]
                        HStack {
                            // Rank Icon
                            viewModel.rankIcon(for: index + 1)
                                .font(.system(size: 30))
                                .foregroundColor(index < 3 ? .blue : .gray)
                                .frame(width: 30, alignment: .center)
                            
                            // User Info
                            VStack(alignment: .leading) {
                                Text(user.name)
                                    .font(.headline)
                                Text("Achievement Points: \(user.achievementPoint)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .navigationTitle("Leaderboard")
            .onAppear {
                if let token = UserDefaults.standard.string(forKey: "authToken") {
                    viewModel.fetchLeaderboardData(bearerToken: token)
                } else {
                    print("Error: No bearer token found.")
                    viewModel.errorMessage = "You must be logged in to view the leaderboard."
                }
            }
        }
    }
}

#Preview {
    LeaderboardView()
}
