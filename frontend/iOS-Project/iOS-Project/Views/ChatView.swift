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
            // Header with Chat Title and Add Button
            HStack {
                Text(viewModel.groupName)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Button(action: {
                    print("Add person to chat room")
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
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

//    private var messageList: some View {
//        ScrollView {
//            ScrollViewReader { proxy in
//                VStack(spacing: 12) {
//                    // Display the messages in reverse order for correct chronological display
//                    ForEach(Array(viewModel.messages.reversed().enumerated()), id: \.offset) { index, message in
//                        MessageRow(message: message, isCurrentUser: message.senderId == viewModel.currentUserId)
//                            .id(message.id) // This remains for animation purposes
//                    }
//                }
//                .onChange(of: viewModel.messages) { _, newMessages in
//                    if let lastMessage = newMessages.last {
//                        // Scroll to the bottom to show the most recent message
//                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
//                    }
//                }
//            }
//        }
//    }
    private var messageList: some View {
        ScrollView {
            ScrollViewReader { proxy in
                VStack(spacing: 12) {
                    ForEach(viewModel.messages.reversed(), id: \.id) { message in
                        MessageRow(message: message, isCurrentUser: message.senderId == viewModel.currentUserId)
                    }
                }
                .onAppear {
                    if let lastMessage = viewModel.messages.last {
                        print(lastMessage.content)
                        DispatchQueue.main.async {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: viewModel.messages) { _, newMessages in
                    if let lastMessage = newMessages.last {
                        DispatchQueue.main.async {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
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
        currentUserName: "Aric Or",
        groupName: "SAMPLE CHAT"
    ))
}
