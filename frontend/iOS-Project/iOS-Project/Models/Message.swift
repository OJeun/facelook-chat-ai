//
//  Message.swift
//  iOS-Project
//
//  Created by Aric Or on 2024-12-02.
//

import Foundation

struct Message: Identifiable, Codable, Equatable {
    let id: UUID
    let content: String
    let senderId: String
    let senderName: String
    let groupId: String
    let createdAt: String

    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        if let date = ISO8601DateFormatter().date(from: createdAt) {
            return formatter.string(from: date)
        }
        return createdAt
    }
}
