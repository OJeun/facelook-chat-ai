//
//  HomeView.swift
//  iOS-Project
//
//  Created by Aric Or on 2024-11-01.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewViewModel
    let userID: Int
    let userName: String
    
    init(userID: Int, userName: String) {
        self.userID = userID
        self.userName = userName
        _viewModel = ObservedObject(wrappedValue: HomeViewViewModel(userID: userID))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                HeaderView(
                    title: "Search",
                    subtitle: "Find your groups",
                    angle: 0,
                    backColor: .blue,
                    image: "logo"
                )
                SearchView()
                
                // Group Content
                VStack {
                    if viewModel.isLoading {
                        ProgressView()
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    } else if $viewModel.groups.isEmpty {
                        Text("You have no groups.")
                            .foregroundColor(.gray)
                            .font(.headline)
                    } else {
                        List(viewModel.groups) { group in
                            GroupView(group: group) {
                            viewModel.selectedGroup = group
                            }
                            
                            .sheet(item: $viewModel.selectedGroup) { group in
                                ChatView(viewModel: ChatViewViewModel(
                                    groupId: group.id,
                                    currentUserId: "\(userID)",
                                    currentUserName: userName,
                                    groupName: group.name
                                ))
                            }
                        }
                        .listStyle(PlainListStyle())
                        .frame(maxHeight: 200)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 200)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                        .padding(.horizontal, 16)
                
                // Create Group Button
                Button("Create Group") {
                    viewModel.showCreateGroupForm = true
                }
                .padding()
                .buttonStyle(.borderedProminent)
                .sheet(isPresented: $viewModel.showCreateGroupForm) {
                    VStack {
                        Text("Create a New Group")
                            .font(.headline)
                        TextField("Group Name", text: $viewModel.groupName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        Button("Submit") {
                            viewModel.createGroup()
                        }
                        .padding()
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
        }
    }
}


#Preview {
    HomeView( userID: 22, userName: "Aric Or")
}

