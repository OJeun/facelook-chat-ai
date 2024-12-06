//
//  HomeViewViewModel.swift
//  iOS-Project
//
//  Created by Fiona Wong on 2024-12-05.
//

import SwiftUI
import Combine


class HomeViewViewModel: ObservableObject {
    @Published var groups: [UserGroup] = []
    @Published var selectedGroup: UserGroup? = nil
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil
    @Published var showCreateGroupForm: Bool = false
    @Published var groupName: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let userID: Int
    
    init(userID: Int) {
        self.userID = userID
        fetchGroups()
    }
    
    func fetchGroups() {
        guard let url = URL(string: "https://ios-project.onrender.com/api/group/list/\(userID)") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            errorMessage = "No authorization token found. Please log in again."
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to load groups: \(error.localizedDescription)"
                    self?.isLoading = false
                    return
                }

                guard let data = data else {
                    self?.errorMessage = "No data received"
                    self?.isLoading = false
                    return
                }

                do {
                    let decodedResponse = try JSONDecoder().decode(GroupListResponse.self, from: data)
                    self?.groups = decodedResponse.groupList
                    self?.isLoading = false
                } catch {
                    self?.errorMessage = "Failed to decode groups: \(error.localizedDescription)"
                    self?.isLoading = false
                }
            }
        }.resume()
    }
    
    func createGroup() {
        guard let url = URL(string: "https://ios-project.onrender.com/api/group/create") else {
            errorMessage = "Invalid URL"
            return
        }

        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            errorMessage = "No authorization token found. Please log in again."
            return
        }

        let body: [String: Any] = [
            "name": groupName,
            "creatorId": userID
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to create group: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    self?.errorMessage = "No data received"
                    return
                }

                do {
                    let decodedResponse = try JSONDecoder().decode(CreateGroupResponse.self, from: data)
                    self?.groups.append(UserGroup(id: decodedResponse.group.groupId, name: decodedResponse.group.groupName))
                    self?.showCreateGroupForm = false
                } catch {
                    self?.errorMessage = "Failed to decode response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
