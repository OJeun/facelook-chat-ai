//
//  ChatView.swift
//  iOS-Project
//
//  Created by Aric Or on 2024-12-02.
//

import SwiftUI

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewViewModel
    @State private var showSendInvitationView = false
    @State private var newMessage: String = ""

    var body: some View {
        VStack {
            // Header with Chat Title and Add Button
            HStack {
                Text(viewModel.groupName)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Button(action: {
                    showSendInvitationView = true
                }) {
                    Image(systemName: "person.badge.plus")
                        .font(.title2)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
                .sheet(isPresented: $showSendInvitationView) {
                    SendInvitationView(
                        viewModel: SendInvitationViewViewModel(
                            groupId: viewModel.groupId,
                            currentUserId: Int(viewModel.currentUserId) ?? 0
                        )
                    )
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)

            Divider()

            // Message List
            messageList

            // Input Field
            HStack {
                TextField("Type a message...", text: $viewModel.newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    viewModel.sendMessage()
                }) {
                    Text("Send")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.connectWebSocket()
        }
    }

    private var messageList: some View {
        ScrollView {
            ScrollViewReader { proxy in
                VStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        MessageRow(
                            message: message,
                            isCurrentUser: message.senderId == viewModel.currentUserId,
                            onEmojiTap: { emoji in
                                viewModel.addEmoji(emoji, toMessageId: message.id)
                            }
                        )
                        .id(message.id)
                    }
                }
                .onChange(of: viewModel.messages) { _, newMessages in
                    if let lastMessage = newMessages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
}

struct MessageRow: View {
    let message: Message
    let isCurrentUser: Bool
    let onEmojiTap: (String) -> Void

    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
                VStack(alignment: .trailing) {
                    ZStack(alignment: .bottomTrailing) {
                        Text(message.content)
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(10)
                            .onTapGesture {
                                onEmojiTap("👍")
                            }

                        if let emoji = message.emoji {
                            Text(emoji)
                                .font(.title3)
                                .padding(4)
                                .background(Color.white.opacity(0.8))
                                .clipShape(Circle())
                                .offset(x: 5, y: 5)
                        }
                    }
                    Text(message.formattedTimestamp)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            } else {
                VStack(alignment: .leading) {
                    Text(message.senderName)
                        .font(.caption)
                        .foregroundColor(.gray)
                    ZStack(alignment: .bottomTrailing) {
                        Text(message.content)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .onTapGesture {
                                onEmojiTap("👍")
                            }

                        if let emoji = message.emoji {
                            Text(emoji)
                                .font(.title3)
                                .padding(4)
                                .background(Color.white.opacity(0.8))
                                .clipShape(Circle())
                                .offset(x: 5, y: 5)
                        }
                    }
                    Text(message.formattedTimestamp)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    ChatView(viewModel: ChatViewViewModel(
        groupId: 1, // Int for fetching the group
        currentUserId: "22",
        currentUserName: "Aric Or",
        groupName: "SAMPLE CHAT"
    ))
}
