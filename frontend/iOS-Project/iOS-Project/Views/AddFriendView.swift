//
//  AddFriendView.swift
//  diane-nogada
//
//  Created by Dianna on 2024-12-04.
//

import SwiftUI

struct AddFriendView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var addFriendViewModel = AddFriendViewViewModel()
    @StateObject private var friendListViewModel = FriendListViewViewModel()
    @State private var email: String = ""
    @State private var showMessage: Bool = false
    @State private var responseMessage: String = ""
    @State private var errorMessage: String? = ""

    var body: some View {
        NavigationView {
            ScrollView { // ScrollView로 전체 뷰를 감쌈
                VStack(alignment: .leading, spacing: 16) {
                    // Add New Friend Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Add New Friend")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.horizontal)

                        TextField("Enter friend's email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .padding(.horizontal)

                        Button(action: {
                            if email.isEmpty {
                                errorMessage = "Please enter email."
                            } else if !isValidEmail(email) {
                                errorMessage = "Invalid email format!"
                            } else {
                                errorMessage = nil
                                addFriendViewModel.sendFriendRequest(receiverEmail: email) { message in
                                    responseMessage = message
                                    showMessage = true
                                    if message == "Friend request sent successfully!" {
                                        friendListViewModel.fetchFriends()
                                    }
                                }
                            }
                        }) {
                            Text("Send Friend Request")
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                        .alert(isPresented: $showMessage) {
                            Alert(
                                title: Text(responseMessage == "Friend request sent successfully!" ? "Success" : "Error")
                                    .foregroundColor(responseMessage == "Friend request sent successfully!" ? .blue : .red),
                                message: Text(responseMessage),
                                dismissButton: .default(Text("OK")) {
                                    if responseMessage == "Friend request sent successfully!" {
                                        dismiss()
                                    }
                                }
                            )
                        }

                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .padding(.horizontal)
                        }
                    }

                    Divider()
                        .padding(.vertical)

                    // My Friend List Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("My Friend List")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.horizontal)

                        if !friendListViewModel.errorMessage.isEmpty {
                            Text(friendListViewModel.errorMessage)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        } else if friendListViewModel.friends.isEmpty {
                            Text("No friends found. Please add from above.")
                                .foregroundColor(.gray)
                                .font(.headline)
                                .padding(.horizontal)
                        } else {
                            List {
                                ForEach(friendListViewModel.friends, id: \.friendId) { friend in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(friend.name)
                                                .font(.headline)
                                            Text("Email: \(friend.email)")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(.vertical, 8)
                                }
                                .onDelete(perform: deleteFriend)
                            }
                            .listStyle(PlainListStyle())
                            .frame(maxHeight: 300)
                        }
                    }
                }
                .padding(.top, 16)
            }
            .onAppear {
                friendListViewModel.fetchFriends()
            }
            .navigationTitle("Friends")
            .navigationBarItems(leading: Button(action: {
                dismiss()
            }) {
            })
        }
    }

    private func deleteFriend(at offsets: IndexSet) {
        for index in offsets {
            if let friendId = friendListViewModel.friends[index].friendId {
                friendListViewModel.removeFriend(friendId: friendId)
            }
        }
        friendListViewModel.friends.remove(atOffsets: offsets)
    }

    private func isValidEmail(_ email: String) -> Bool {
        if !email.contains("@") || !email.contains(".") {
            return false
        } else { return true }
    }
}

#Preview {
    AddFriendView()
}
