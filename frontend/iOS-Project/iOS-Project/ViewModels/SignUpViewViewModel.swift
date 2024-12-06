//
//  SignUpViewViewModel.swift
//  iOS-Project
//
//  Created by Diane Choi on 2024-12-05.
//

import Foundation
import Combine

class SignUpViewViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var name: String = ""
    @Published var errorMessage: String = ""
    @Published var userId: Int? = nil
    
    private var cancellables = Set<AnyCancellable>()

    func signUp(onSuccess: @escaping (Int, String, String) -> Void) {
        errorMessage = ""

        guard validateInput() else { return }

        let url = URL(string: "https://ios-project.onrender.com/api/auth/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "email": email,
            "password": password,
            "name": name
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
                    self?.errorMessage = "Register failed: \(error.localizedDescription)"
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                self?.handleSuccessfulSignUp(response: response, onSuccess: onSuccess)
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

    private func handleSuccessfulSignUp(response: LoginResponse, onSuccess: @escaping (Int, String, String) -> Void) {
        onSuccess(response.user.userId, response.user.name, response.user.email)

        print("Register successful!")
        print("User Details:")
        print("  UserID: \(response.user.userId)")
        print("  Name: \(response.user.name)")
        print("  Email: \(response.user.email)")
        
    }

}
