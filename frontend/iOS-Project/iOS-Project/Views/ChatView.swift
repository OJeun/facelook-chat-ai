//
//  ChatView.swift
//  iOS-Project
//
//  Created by Aric Or on 2024-12-02.
//

import SwiftUI

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewViewModel

    var body: some View {
        VStack {
            // Message List
            messageList

            // Input Field
            HStack {
                TextField("Type a message...", text: $viewModel.newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: viewModel.sendMessage) {
                    Text("Send")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var messageList: some View {
        ScrollView {
            ScrollViewReader { proxy in
                VStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        MessageRow(message: message, isCurrentUser: message.senderId == viewModel.currentUserId)
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

    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
                VStack(alignment: .trailing) {
                    Text(message.content)
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)
                    Text(message.formattedTimestamp)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            } else {
                VStack(alignment: .leading) {
                    Text(message.senderName)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(message.content)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
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
        currentUserName: "Aric Or"
    ))
}
