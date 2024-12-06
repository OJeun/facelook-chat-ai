//
//  ProfileViewViewModel.swift
//  diane-nogada
//
//  Created by Dianna on 2024-12-05.
//

import Foundation

class ProfileViewViewModel: ObservableObject {
    @Published var user: User?
    @Published var errorMessage: String = ""

    private let baseUrl = "https://ios-project.onrender.com"

    func fetchUserProfile() {
        guard let userId = UserDefaults.standard.value(forKey: "userID") as? Int,
              let token = UserDefaults.standard.string(forKey: "authToken") else {
            DispatchQueue.main.async {
                self.errorMessage = "User not logged in. Please log in again."
            }
            return
        }

        guard let url = URL(string: "\(baseUrl)/api/user/\(userId)") else {
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
                    self.errorMessage = "Failed to fetch user profile: \(error.localizedDescription)"
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                  let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch user profile: Invalid server response."
                }
                return
            }

            do {
                let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)
                DispatchQueue.main.async {
                    self.user = userResponse.user
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to parse user profile: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    func logout() {
            // Clear stored data
            UserDefaults.standard.removeObject(forKey: "authToken")
            UserDefaults.standard.removeObject(forKey: "userID")
            UserDefaults.standard.removeObject(forKey: "userName")
        }

}
