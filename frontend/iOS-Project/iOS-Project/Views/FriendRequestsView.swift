//
//  FriendRequestsView.swift
//  diane-nogada
//
//  Created by Dianna on 2024-12-04.
//

import SwiftUI

struct FriendRequestsView: View {
    @StateObject private var viewModel = FriendRequestsViewViewModel()

    var body: some View {
        NavigationView {
            VStack {
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                if viewModel.requests.isEmpty {
                    Text("No friend requests.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.requests, id: \.id) { request in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(request.senderName ?? "Unknown")
                                        .font(.headline)
                                    Text("Email: \(request.senderEmail ?? "Unknown")")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                Button("Accept") {
                                    viewModel.acceptRequest(requestId: request.id ?? 0) { message in
                                        viewModel.fetchRequests() // Refresh the list
                                    }
                                }
                                .buttonStyle(.bordered)

                                Button("Reject") {
                                    viewModel.rejectRequest(requestId: request.id ?? 0) { message in
                                        viewModel.fetchRequests() // Refresh the list
                                    }
                                }
                                .buttonStyle(.bordered)
                                .foregroundColor(.red)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .onAppear {
                viewModel.fetchRequests()
            }
            .navigationTitle("Friend Requests")
        }
    }
}

#Preview {
    FriendRequestsView()
}
