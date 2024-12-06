//
//  HomeView.swift
//  iOS-Project
//
//  Created by Aric Or on 2024-11-01.
//

import SwiftUI

// Align the UserGroup struct with the API response
struct UserGroup: Identifiable, Codable {
    let id: Int // Updated to Int for groupId
    let name: String

    enum CodingKeys: String, CodingKey {
        case id = "groupId"
        case name = "groupName"
    }
}

struct GroupListResponse: Codable {
    let groupList: [UserGroup]
}

struct CreateGroupResponse: Codable {
    let message: String
    let group: GroupDetails
}

struct GroupDetails: Codable {
    let lastChatId: String? // Nullable field
    let groupId: Int
    let groupName: String
}

struct HomeView: View {
    let userID: Int
    let userName: String // Include user's name for displaying in ChatView
    @State private var groups: [UserGroup] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil
    @State private var showCreateGroupForm = false
    @State private var groupName = ""
    @State private var selectedGroup: UserGroup?

    var body: some View {
        NavigationStack {
            VStack {
                // Top Navigation Bar
                HStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 36)
                        .foregroundColor(.gray.opacity(0.2))
                        .overlay(
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                Text("Search")
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                        )
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .imageScale(.large)
                        .padding(.trailing)
                }
                .padding(.vertical)

                // Group Content
                VStack {
                    if isLoading {
                        ProgressView()
                    } else if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    } else if groups.isEmpty {
                        Text("You have no groups.")
                            .foregroundColor(.gray)
                            .font(.headline)
                    } else {
                        List(groups) { group in
                            Button(action: {
                                selectedGroup = group
                            }) {
                                Text(group.name)
                                    .font(.headline)
                                    .padding(.vertical, 8)
                            }
                            .sheet(item: $selectedGroup) { group in
                                ChatView(viewModel: ChatViewViewModel(
                                    groupId: group.id, // Int for groupId
                                    currentUserId: "\(userID)",
                                    currentUserName: userName,
                                    groupName: group.name
                                ))
                            }
                        }
                    }
                }
                .padding()

                // Create Group Button
                HStack(spacing: 16) {
                    Button("Create Group") {
                        showCreateGroupForm = true
                    }
                    .buttonStyle(.borderedProminent)

                    NavigationLink(destination: InvitationView()) {
                        Text("View Invitations")
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
                .buttonStyle(.borderedProminent)
            }
            .sheet(isPresented: $showCreateGroupForm) {
                VStack {
                    Text("Create a New Group")
                        .font(.headline)
                    TextField("Group Name", text: $groupName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    Button("Submit") {
                        createGroup()
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .onAppear {
                fetchGroups()
            }
        }
    }

    // Fetch Groups Function
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

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Failed to load groups: \(error.localizedDescription)"
                    self.isLoading = false
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data received"
                    self.isLoading = false
                    return
                }

                do {
                    let decodedResponse = try JSONDecoder().decode(GroupListResponse.self, from: data)
                    self.groups = decodedResponse.groupList
                    self.isLoading = false
                } catch {
                    self.errorMessage = "Failed to decode groups: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }.resume()
    }

    // Create Group Function
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

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Failed to create group: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }

                do {
                    let decodedResponse = try JSONDecoder().decode(CreateGroupResponse.self, from: data)
                    print("Group created successfully: \(decodedResponse)")
                    fetchGroups() // Refresh groups
                    showCreateGroupForm = false
                } catch {
                    self.errorMessage = "Failed to decode response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

#Preview {
    HomeView(userID: 22, userName: "Aric Or")
}
