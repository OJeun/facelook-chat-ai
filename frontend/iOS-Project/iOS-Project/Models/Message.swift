//
//  Message.swift
//  iOS-Project
//
//  Created by Aric Or on 2024-12-02.
//

import Foundation

struct Message: Identifiable, Codable, Equatable {
    let id: String
    let content: String
    let senderId: String
    let senderName: String
    let groupId: String
    let createdAt: String
    var emoji: String?

    var formattedTimestamp: String {
        let isoDateFormatter = ISO8601DateFormatter()
        guard let date = isoDateFormatter.date(from: createdAt) else {
            return createdAt // Fallback to original string if parsing fails
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a, MMM d, yyyy" // 12-hour format with AM/PM
        return dateFormatter.string(from: date)
    }
}

struct WebSocketResponse: Decodable {
    let type: String
    let messages: [Message]?
}
