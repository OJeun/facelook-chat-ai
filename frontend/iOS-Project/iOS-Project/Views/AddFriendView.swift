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

    var body: some View {
        NavigationView {
            VStack {
                // Add Friend Form
                TextField("Enter friend's email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    addFriendViewModel.sendFriendRequest(receiverEmail: email) { message in
                        responseMessage = message
                        showMessage = true
                        if message == "Friend request sent successfully!" {
                            friendListViewModel.fetchFriends() // 친구 목록 갱신
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
                        title: Text("Response"),
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
            .navigationTitle("Add Friend & Friends List")
            .navigationBarItems(leading: Button(action: {
                dismiss()
            }) {
                Text("Cancel")
                    .foregroundColor(.red)
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
}

#Preview {
    AddFriendView()
}
