//
//  SendInvitationViewViewModel.swift
//  iOS-Project
//
//  Created by Diane Choi on 2024-12-05.
//

import Foundation

import Foundation

class SendInvitationViewViewModel: ObservableObject {
    @Published var friends: [Friend] = []
    @Published var errorMessage: String = ""
    private let baseUrl = "https://ios-project.onrender.com"

    let groupId: Int
    let currentUserId: Int

    init(groupId: Int, currentUserId: Int) {
        self.groupId = groupId
        self.currentUserId = currentUserId
    }

    func fetchFriends() {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            DispatchQueue.main.async {
                self.errorMessage = "Authentication token is missing."
            }
            return
        }

        guard let url = URL(string: "\(baseUrl)/api/friend/\(currentUserId)") else {
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

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch friends: No data received."
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

    func sendChatInvitation(receiverId: Int, completion: @escaping (String) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            DispatchQueue.main.async {
                completion("Authentication token is missing.")
            }
            return
        }

        guard let url = URL(string: "\(baseUrl)/api/invitation/send") else {
            DispatchQueue.main.async {
                completion("Invalid URL")
            }
            return
        }

        let body: [String: Any] = [
            "receiverId": receiverId,
            "senderId": currentUserId,
            "groupId": groupId
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion("Failed to send invitation: \(error.localizedDescription)")
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion("Failed to send invitation: Invalid server response.")
                }
                return
            }

            DispatchQueue.main.async {
                completion("Invitation sent successfully!")
            }
        }.resume()
    }
}
