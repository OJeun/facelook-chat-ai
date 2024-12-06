//
//  FriendListViewViewModel.swift
//  diane-nogada
//
//  Created by Dianna on 2024-12-05.
//

import Foundation

class FriendListViewViewModel: ObservableObject {
    @Published var friends: [Friend] = []
    @Published var errorMessage: String = ""

    private let baseUrl = "https://ios-project.onrender.com"

    func fetchFriends() {
        guard let userId = UserDefaults.standard.value(forKey: "userID") as? Int,
              let token = UserDefaults.standard.string(forKey: "authToken") else {
            DispatchQueue.main.async {
                self.errorMessage = "User not logged in. Please log in again."
            }
            return
        }

        guard let url = URL(string: "\(baseUrl)/api/friend/\(userId)") else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch friends: \(error.localizedDescription)"
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                  let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch friends: Invalid server response."
                }
                return
            }

            do {
                let friendResponse = try JSONDecoder().decode(FriendResponse.self, from: data)
                DispatchQueue.main.async {
                    self.friends = friendResponse.friends
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to parse friends: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    func removeFriend(friendId: Int) {
        guard let userId = UserDefaults.standard.value(forKey: "userID") as? Int,
              let token = UserDefaults.standard.string(forKey: "authToken") else {
            DispatchQueue.main.async {
                self.errorMessage = "Authentication token or userId is missing."
            }
            return
        }

        guard let url = URL(string: "\(baseUrl)/api/friend/delete") else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["userId": userId, "friendId": friendId])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to remove friend: \(error.localizedDescription)"
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to remove friend: Invalid server response."
                }
                return
            }

            DispatchQueue.main.async {
                self.friends.removeAll { $0.friendId == friendId }
            }
        }.resume()
    }
}
