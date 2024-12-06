//
//  FriendRequestsViewViewModel.swift
//  diane-nogada
//
//  Created by Dianna on 2024-12-05.
//

import Foundation

class FriendRequestsViewViewModel: ObservableObject {
    @Published var requests: [FriendRequest] = []
    @Published var errorMessage: String = ""

    private let baseUrl = "https://ios-project.onrender.com"

    func fetchRequests() {
        guard let receiverId = UserDefaults.standard.value(forKey: "userID") as? Int,
              let token = UserDefaults.standard.string(forKey: "authToken") else {
            DispatchQueue.main.async {
                self.errorMessage = "User not logged in. Please log in again."
            }
            return
        }

        guard let url = URL(string: "\(baseUrl)/api/friend/request/\(receiverId)") else {
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
                    self.errorMessage = "Failed to fetch requests: \(error.localizedDescription)"
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                  let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch requests: Invalid server response."
                }
                return
            }

            do {
                if let requestResponse = try? JSONDecoder().decode([FriendRequest].self, from: data) {
                    DispatchQueue.main.async {
                        self.requests = requestResponse
                        self.errorMessage = ""
                    }
                } else {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.requests = [] // Clear requests
                        self.errorMessage = errorResponse.message
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to parse requests: \(error.localizedDescription)"
                }
            }
        }.resume()
    }


    func acceptRequest(requestId: Int, completion: @escaping (String) -> Void) {
        performAction(for: requestId, action: "accept", completion: completion)
    }

    func rejectRequest(requestId: Int, completion: @escaping (String) -> Void) {
        performAction(for: requestId, action: "reject", completion: completion)
    }

    private func performAction(for requestId: Int, action: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "\(baseUrl)/api/friend/request/\(action)"),
              let token = UserDefaults.standard.string(forKey: "authToken") else {
            DispatchQueue.main.async {
                completion("Invalid URL or missing token.")
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["requestId": requestId])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion("Failed to \(action) request: \(error.localizedDescription)")
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion("Failed to \(action) request: Invalid server response.")
                }
                return
            }

            DispatchQueue.main.async {
                completion("Request \(action)ed successfully!")
            }
        }.resume()
    }
}
