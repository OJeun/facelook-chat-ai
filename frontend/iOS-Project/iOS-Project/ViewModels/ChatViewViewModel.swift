import Foundation
import Combine

// Add new struct for emoji response
struct EmojiResponse: Codable {
    let emoji: String
    let userId: String
    let messageId: String
}

struct WebSocketResponse: Codable {
    let type: String
    let messages: [Message]?
    let emojis: [EmojiResponse]?
}

class ChatViewViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var newMessage: String = ""
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var cancellables = Set<AnyCancellable>()
    
    let groupId: Int
    let currentUserId: String
    let currentUserName: String
    let groupName: String
    
    init(groupId: Int, currentUserId: String, currentUserName: String, groupName: String) {
        self.groupId = groupId
        self.currentUserId = currentUserId
        self.currentUserName = currentUserName
        self.groupName = groupName
        connectWebSocket()
    }
    
    deinit {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    func connectWebSocket() {
        guard webSocketTask == nil else {
            print("WebSocket already connected")
            return
        }
        
        guard let url = URL(string: "wss://ios-project.onrender.com/ws?groupId=\(groupId)") else {
            print("Invalid WebSocket URL")
            return
        }
        
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()
        
        receiveMessage()
    }
    
    func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print("WebSocket error: \(error.localizedDescription)")
            case .success(let message):
                self.handleWebSocketMessage(message)
            }
            
            // Continue listening for the next message
            self.receiveMessage()
        }
    }
    
    private func handleWebSocketMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            if let data = text.data(using: .utf8),
               let response = try? JSONDecoder().decode(WebSocketResponse.self, from: data) {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    switch response.type {
                    case "recentMessages":
                        if let messages = response.messages {
                            self.messages.append(contentsOf: messages)
                        }
                    case "newMessage":
                        if let messages = response.messages, let newMessage = messages.first {
                            if !self.messages.contains(where: { $0.id == newMessage.id }) {
                                self.messages.append(newMessage)
                            }
                        }
                    case "newEmojis":
                        if let emojis = response.emojis {
                            self.updateMessagesWithEmojis(emojis)
                        }
                    default:
                        print("Unknown message type: \(response.type)")
                    }
                }
            }
        default:
            print("Unsupported message type")
        }
    }
    
    private func updateMessagesWithEmojis(_ emojis: [EmojiResponse]) {
        var updatedMessages = self.messages
        
        for emoji in emojis {
            if let index = updatedMessages.firstIndex(where: { $0.id == emoji.messageId }) {
                updatedMessages[index].emoji = emoji.emoji
            } else {
                print("Warning: Message not found for emoji: \(emoji)")
            }
        }
        
        self.messages = updatedMessages
    }
    
    func sendMessage() {
        guard !newMessage.isEmpty else { return }
        
        let message = Message(
            id: UUID().uuidString,
            content: newMessage,
            senderId: currentUserId,
            senderName: currentUserName,
            groupId: String(groupId),
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
        
        if let data = try? JSONEncoder().encode(message) {
            webSocketTask?.send(.data(data)) { error in
                if let error = error {
                    print("Failed to send message: \(error)")
                }
            }
        }
        
        // Add the message locally for instant UI feedback
        // DispatchQueue.main.async {
           // self.messages.append(message)
            // self.newMessage = ""
        // }
    }
}
