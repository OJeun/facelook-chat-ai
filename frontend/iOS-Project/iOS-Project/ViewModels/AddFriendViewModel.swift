//
//  AddFriendViewModel.swift
//  diane-nogada
//
//  Created by Dianna on 2024-12-04.
//

import Foundation

class AddFriendViewViewModel: ObservableObject {
    @Published var errorMessage: String = ""

    private let baseUrl = "https://ios-project.onrender.com"

    func sendFriendRequest(receiverEmail: String, completion: @escaping (String) -> Void) {
        guard let senderId = UserDefaults.standard.value(forKey: "userID") as? Int,
              let token = UserDefaults.standard.string(forKey: "authToken") else {
            DispatchQueue.main.async {
                completion("Authentication token or userId is missing.")
            }
            return
        }

        guard let url = URL(string: "\(baseUrl)/api/friend/request/send") else {
            DispatchQueue.main.async {
                completion("Invalid URL")
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let friendRequest = FriendRequest(
            id: nil,
            senderId: senderId,
            receiverEmail: receiverEmail,
            senderName: nil,
            senderEmail: nil,
            status: nil
        )
        request.httpBody = try? JSONEncoder().encode(friendRequest)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion("Failed to send request: \(error.localizedDescription)")
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                  let data = data else {
                DispatchQueue.main.async {
                    completion("Failed to send request: Invalid server response.")
                }
                return
            }

            do {
                let responseMessage = try JSONDecoder().decode(ResponseMessage.self, from: data)
                DispatchQueue.main.async {
                    completion(responseMessage.message)
                }
            } catch {
                DispatchQueue.main.async {
                    completion("Failed to parse server response.")
                }
            }
        }.resume()
    }
}
