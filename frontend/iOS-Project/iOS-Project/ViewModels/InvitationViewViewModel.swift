//
//  InvitationViewViewModel.swift
//  iOS-Project
//
//  Created by Diane Choi on 2024-12-05.
//

import Foundation

class InvitationViewViewModel: ObservableObject {
    @Published var invitations: [Invitation] = []
    @Published var errorMessage: String = ""
    private let baseUrl = "https://ios-project.onrender.com"

    // Fetch Invitations Function
    func fetchInvitations() {
        guard let userId = UserDefaults.standard.value(forKey: "userID") as? Int,
              let token = UserDefaults.standard.string(forKey: "authToken") else {
            self.errorMessage = "User not logged in. Please log in again."
            return
        }

        guard let url = URL(string: "https://ios-project.onrender.com/api/invitation/\(userId)") else {
            self.errorMessage = "Invalid URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Failed to fetch invitations: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }

                do {
                    let decodedResponse = try JSONDecoder().decode(InvitationResponse.self, from: data)
                    self.invitations = decodedResponse.invitations
                    print(self.invitations)
                    self.errorMessage = ""
                } catch {
                    self.errorMessage = "Failed to decode invitations: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    
    func acceptInvitation(id: Int, completion: @escaping (String) -> Void) {
        performAction(for: id, action: "accept", completion: completion)
    }

    func rejectInvitation(id: Int, completion: @escaping (String) -> Void) {
        performAction(for: id, action: "reject", completion: completion)
    }

    private func performAction(for id: Int, action: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "\(baseUrl)/api/invitation/\(action)"),
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
        request.httpBody = try? JSONEncoder().encode(["invitationId": id])

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
                completion("Invitation \(action)ed successfully!")
            }
        }.resume()
    }
}
