//
//  LoginViewViewModel.swift
//  iOS-Project
//
//  Created by Aric Or on 2024-11-30.
//

import Foundation
import SwiftUI
import Combine

class LoginViewViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String = ""
    @Published var token: String? = nil
    @Published var userId: Int? = nil

    private var cancellables = Set<AnyCancellable>()

    func login(onSuccess: @escaping (Int, String) -> Void) {
        errorMessage = ""

        guard validateInput() else { return }

        let url = URL(string: "https://ios-project.onrender.com/api/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "email": email,
            "password": password
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result -> LoginResponse in
                guard let httpResponse = result.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return try JSONDecoder().decode(LoginResponse.self, from: result.data)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.errorMessage = "Login failed: \(error.localizedDescription)"
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                self?.handleSuccessfulLogin(response: response, onSuccess: onSuccess)
            })
            .store(in: &cancellables)
    }

    private func validateInput() -> Bool {
        if email.trimmingCharacters(in: .whitespaces).isEmpty || password.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Please fill in all fields."
            return false
        }

        if !email.contains("@") || !email.contains(".") {
            errorMessage = "Please enter a valid email address."
            return false
        }

        return true
    }

    private func handleSuccessfulLogin(response: LoginResponse, onSuccess: @escaping (Int, String) -> Void) {
        // Store the token and userId
        self.token = response.token
        self.userId = response.user.userId

        // Save the token, userId, and optionally userName for future use
        UserDefaults.standard.set(response.token, forKey: "authToken")
        UserDefaults.standard.set(response.user.userId, forKey: "userID")
        UserDefaults.standard.set(response.user.name, forKey: "userName")

        // Notify via callback with userId and userName
        onSuccess(response.user.userId, response.user.name)

        print("Login successful!")
        print("User Details:")
        print("  UserID: \(response.user.userId)")
        print("  Name: \(response.user.name)")
        print("  Achievement Points: \(response.user.achievementPoint)")
        print("  Token: \(response.token!)")
    }

    static func getAuthorizationHeader() -> [String: String]? {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            return nil
        }
        return ["Authorization": "Bearer \(token)"]
    }
}
