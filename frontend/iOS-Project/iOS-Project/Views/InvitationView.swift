//
//  InvitationView.swift
//  iOS-Project
//
//  Created by Diane Choi on 2024-12-05.
//

import SwiftUI

struct InvitationView: View {
    @StateObject private var viewModel = InvitationViewViewModel()

    var body: some View {
        VStack {
            if viewModel.invitations.isEmpty {
                Text("You have no invitations.")
                    .foregroundColor(.gray)
                    .font(.headline)
                    .padding()
            } else {
                List(viewModel.invitations, id: \.id) { invitation in
                    InvitationRow(invitation: invitation, viewModel: viewModel)
                        .padding(.vertical, 8)
                }
            }

            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .navigationTitle("Your Invitations")
        .onAppear {
            viewModel.fetchInvitations()
        }
    }
}

struct InvitationRow: View {
    let invitation: Invitation
    @ObservedObject var viewModel: InvitationViewViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(invitation.groupName)
                .font(.headline)
            Text("From: \(invitation.senderName)")
                .font(.subheadline)

            HStack {
                Button("Accept") {
                    handleInvitationAction(isAccepting: true)
                }
                .buttonStyle(.borderedProminent)

                Button("Reject") {
                    handleInvitationAction(isAccepting: false)
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
            }
        }
    }

    private func handleInvitationAction(isAccepting: Bool) {
        let action = isAccepting ? "accept" : "reject"
        let actionMethod = isAccepting ? viewModel.acceptInvitation : viewModel.rejectInvitation

        actionMethod(invitation.id) { message in
            if message.contains("successfully") {
                withAnimation {
                    viewModel.invitations.removeAll { $0.id == invitation.id }
                }
            } else {
                viewModel.errorMessage = message
            }
        }
    }
}

#Preview {
    InvitationView()
}
