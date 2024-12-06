//
//  LeaderboardViewViewModel.swift
//  iOS-Project
//
//  Created by Aric Or on 2024-12-05.
//

import SwiftUI
import Foundation

class LeaderboardViewViewModel: ObservableObject {
    @Published var users: [UserAchievement] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    func fetchLeaderboardData(bearerToken: String) {
        guard let url = URL(string: "https://ios-project.onrender.com/api/user/achievementPoint") else {
            self.errorMessage = "Invalid URL"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        isLoading = true
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode([String: [UserAchievement]].self, from: data)
                    // Sort the users by achievementPoint in descending order
                    let sortedUsers = (response["users"] ?? []).sorted { $0.achievementPoint > $1.achievementPoint }
                    // Keep only the top 10 users
                    self.users = Array(sortedUsers.prefix(10))
                } catch {
                    self.errorMessage = "Failed to decode response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    func rankIcon(for rank: Int) -> Image {
        if rank <= 3 {
            // Top 3 use filled circle
            return Image(systemName: "\(rank).circle.fill")
        } else {
            // 4th and below use plain circle
            return Image(systemName: "\(rank).circle")
        }
    }
}
