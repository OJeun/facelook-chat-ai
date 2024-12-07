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
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationView {
            VStack {
                // Add Friend Form
                Text("Add New Friend")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.top, 5)
                
                TextField("Enter friend's email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                Button(action: {
                    if validateEmail() {
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
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .alert(isPresented: $showMessage) {
                    Alert(
                        title: Text(responseMessage == "Friend request sent successfully!" ? "Response" : "Error"),
                        message: Text(responseMessage),
                        dismissButton: .default(Text("OK")) {
                            if responseMessage == "Friend request sent successfully!" {
                                dismiss()
                            }
                        }
                    )
                }
                
                Divider()
                    .padding(.vertical)
                
                // Friend List View
                Text("My Friend List")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                
                if !friendListViewModel.errorMessage.isEmpty {
                    Text(friendListViewModel.errorMessage)
                        .foregroundColor(.red)
                        .padding()
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
                }
            }
            .onAppear {
                friendListViewModel.fetchFriends()
            }
            .navigationTitle("Manage Friends")
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
    
    private func validateEmail() -> Bool {
        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Please fill in all fields."
            return false
        }

        if !email.contains("@") || !email.contains(".") {
            errorMessage = "Please enter a valid email address."
            return false
        }

        errorMessage = ""
        return true
    }
}

#Preview {
    AddFriendView()
}
