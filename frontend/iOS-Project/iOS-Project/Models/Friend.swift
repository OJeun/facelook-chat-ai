//
//  Friend.swift
//  diane-nogada
//
//  Created by Dianna on 2024-12-04.
//

import Foundation

struct Friend: Codable {
    let friendId: Int?
    let name: String
    let email: String

    enum CodingKeys: String, CodingKey {
        case friendId
        case name
        case email
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let id = try? container.decode(Int.self, forKey: .friendId) {
            self.friendId = id
        } else if let idString = try? container.decode(String.self, forKey: .friendId),
                  let id = Int(idString) {
            self.friendId = id
        } else {
            self.friendId = nil // Default to nil if decoding fails
        }

        self.name = try container.decode(String.self, forKey: .name)
        self.email = try container.decode(String.self, forKey: .email)
    }
}

struct FriendResponse: Codable {
    let friends: [Friend]
}

struct ErrorResponse: Codable {
    let message: String
}

struct ResponseMessage: Codable {
    let message: String
}

struct FriendRequest: Codable, Identifiable {
    let id: Int?
    let senderId: Int
    let receiverEmail: String?
    let senderName: String?
    let senderEmail: String?
    let status: String?

    enum CodingKeys: String, CodingKey {
        case id = "requestId"
        case senderId
        case receiverEmail
        case senderName
        case senderEmail
        case status
    }
}
