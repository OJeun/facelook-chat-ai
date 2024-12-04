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
        guard let url = URL(string: "wss://ios-project.onrender.com/ws?groupId=\(String(groupId))") else {
            print("Invalid WebSocket URL")
            return
        }
        
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("Unauthorized token")
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        webSocketTask = URLSession.shared.webSocketTask(with: request)
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
                       let receivedMessage = try? JSONDecoder().decode(Message.self, from: data) {
                        DispatchQueue.main.async {
                            self.messages.append(receivedMessage)
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
            id: UUID(),
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
