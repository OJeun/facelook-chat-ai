import Foundation
import Combine

class ChatViewViewModel: ObservableObject {
    @Published var messages: [MessageWithTimestamp] = []
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
        fetchChatHistory()
        connectWebSocket()
    }

    deinit {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }

    func connectWebSocket() {
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
                print("WebSocket error while receiving message: \(error.localizedDescription)")
                if let urlError = error as? URLError {
                    print("URLError code: \(urlError.errorCode), description: \(urlError.localizedDescription)")
                } else if let nsError = error as NSError? {
                    print("NSError: domain = \(nsError.domain), code = \(nsError.code), userInfo = \(nsError.userInfo)")
                } else {
                    print("Unknown WebSocket error: \(error)")
                }
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received text: \(text)")
                    if let data = text.data(using: .utf8),
                       let receivedMessage = try? JSONDecoder().decode(MessageWithTimestamp.self, from: data) {
                        DispatchQueue.main.async {
                            self.messages.append(receivedMessage)
                        }
                    } else {
                        print("Failed to decode message: \(text)")
                    }
                case .data(let data):
                    print("Received data: \(data)")
                @unknown default:
                    print("Unknown WebSocket message type received")
                }
            }

            // Continue listening
            self.receiveMessage()
        }
    }

    func sendMessage() {
        guard !newMessage.isEmpty else { return }

        let message = Message(
            groupId: String(groupId), // Convert groupId to String for sending
            senderId: currentUserId,
            message: newMessage
        )

        if let data = try? JSONEncoder().encode(message) {
            webSocketTask?.send(.data(data)) { error in
                if let error = error {
                    print("Failed to send message: \(error)")
                }
            }
        }
        
        saveMessageToServer(message: message)

        // Add the message locally for instant UI feedback
        DispatchQueue.main.async {
            let timestampedMessage = MessageWithTimestamp(
                groupId: message.groupId,
                senderId: message.senderId,
                message: message.message,
                createdAt: ISO8601DateFormatter().string(from: Date())
            )
            self.messages.append(timestampedMessage)
            self.newMessage = ""
        }
    }
    
    func fetchChatHistory() {
        guard let url = URL(string: "https://ios-project.onrender.com/api/chat/allChats?groupId=\(groupId)&offset=0&limit=50") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(UserDefaults.standard.string(forKey: "authToken") ?? "")", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                print("Failed to fetch chat history: \(error)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let response = try JSONDecoder().decode(ChatHistoryResponse.self, from: data)
                DispatchQueue.main.async {
                    self.messages = response.messages + self.messages
                }
            } catch {
                print("Failed to decode chat history: \(error)")
            }
        }.resume()
    }
    
    func saveMessageToServer(message: Message) {
        guard let url = URL(string: "https://ios-project.onrender.com/api/chat/saveChats") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(UserDefaults.standard.string(forKey: "authToken") ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "groupId": groupId,
            "chatList": [message] // Send as an array
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to save message to server: \(error)")
            } else {
                print("Message saved to server")
            }
        }.resume()
    }

    struct ChatHistoryResponse: Codable {
        let messages: [MessageWithTimestamp]
    }

    struct Message: Codable {
        let groupId: String
        let senderId: String
        let message: String
    }

    struct MessageWithTimestamp: Codable {
        let groupId: String
        let senderId: String
        let message: String
        let createdAt: String
    }
}
