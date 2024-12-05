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

    init(groupId: Int, currentUserId: String, currentUserName: String) {
        self.groupId = groupId
        self.currentUserId = currentUserId
        self.currentUserName = currentUserName
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
        
        print("Query groupId: \(String(self.groupId))")
        guard let url = URL(string: "wss://ios-project.onrender.com/ws?groupId=\(String(self.groupId))") else {
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
                switch message {
                case .string(let text):
                    if let data = text.data(using: .utf8),
                    let response = try? JSONDecoder().decode(WebSocketResponse.self, from: data) {
                        if response.type == "recentMessages", let messages = response.messages {
                            DispatchQueue.main.async {
                                self.messages.append(contentsOf: messages)
                            }
                        }
                    } else {
                        print("Failed to decode message: \(text)")
                    }
                default:
                    break
                }
            }

            self.receiveMessage() // Continue listening
        }
    }

    func sendMessage() {
        guard !newMessage.isEmpty else { return }

        let message = Message(
            id: UUID().uuidString,
            content: newMessage,
            senderId: currentUserId,
            senderName: currentUserName,
            groupId: String(groupId), // Convert groupId to String for sending
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
}
