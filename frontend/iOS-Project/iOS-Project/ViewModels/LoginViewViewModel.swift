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
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""

    private var cancellables = Set<AnyCancellable>()

    func login(onSuccess: @escaping () -> Void) {
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
        if email.isEmpty || password.isEmpty {
            errorMessage = "Please fill in all fields."
            return false
        }

        if !email.contains("@") || !email.contains(".") {
            errorMessage = "Please enter a valid email."
            return false
        }

        return true
    }

    private func handleSuccessfulLogin(response: LoginResponse, onSuccess: @escaping () -> Void) {
        // Log user details
        print("Login successful!")
        print("User Details:")
        print("  UserID: \(response.user.userId)")
        print("  Name: \(response.user.name)")
        print("  Achievement Points: \(response.user.achievementPoint)")
        print("  Token: \(response.token)")

        // Notify via callback
        onSuccess()
    }
}
