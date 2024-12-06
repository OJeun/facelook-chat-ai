//
//  SendInvitationView.swift
//  iOS-Project
//
//  Created by Diane Choi on 2024-12-05.
//

import SwiftUI

struct SendInvitationView: View {
    @ObservedObject var viewModel: SendInvitationViewViewModel
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            VStack {
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else if viewModel.friends.isEmpty {
                    // Display message when no friends are found
                    VStack {
                        Text("You have no friends to add in the chat.")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Add a new friend.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                } else {
                    // Display the list of friends
                    List(viewModel.friends, id: \.friendId) { friend in
                        HStack {
                            Text(friend.name)
                            Spacer()
                            Button("Invite") {
                                viewModel.sendChatInvitation(receiverId: friend.friendId ?? 0) { message in
                                    alertMessage = message
                                    showAlert = true
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }
            .onAppear {
                viewModel.fetchFriends()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Invitation Sent"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .navigationTitle("Send Invitation")
        }
        .presentationDetents([.fraction(0.5), .large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    SendInvitationView(viewModel: SendInvitationViewViewModel(groupId: 5, currentUserId: 2
    ))
}
