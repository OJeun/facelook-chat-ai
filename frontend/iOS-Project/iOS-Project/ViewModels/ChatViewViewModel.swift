import Foundation
import Combine

class ChatViewViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var newMessage: String = ""
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var cancellables = Set<AnyCancellable>()
    
    let groupId: Int // Int for groupId when fetching groups
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
                if response.type == "recentMessages", let messages = response.messages {
                    DispatchQueue.main.async {
                        self.messages.append(contentsOf: messages)
                    }
                } else if response.type == "newMessage", let messages = response.messages, let newMessage = messages.first {
                    DispatchQueue.main.async {
                        if !self.messages.contains(where: { $0.id == newMessage.id }) {
                            self.messages.append(newMessage)
                        }
                    }
                }
            } else {
                print("Failed to decode message: \(text)")
            }
        default:
            print("Unsupported WebSocket message type")
        }
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
        DispatchQueue.main.async {
            self.messages.append(message)
            self.newMessage = ""
        }
    }
    
    func addEmojisToMessages() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            guard let self = self else { return }

            // Example emojis to assign
            let emojis = ["😊", "😋", "😄", "🤔", "😍", "😢", "😡", "😎", "🥳"]
            var updatedMessages = self.messages

            // Assign emojis randomly to the messages
            for i in 0..<updatedMessages.count {
                let randomEmoji = emojis.randomElement() ?? "😃"
                updatedMessages[i].emoji = randomEmoji
            }

            self.messages = updatedMessages
        }
    }
}