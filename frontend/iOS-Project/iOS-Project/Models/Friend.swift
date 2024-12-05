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
        
        // friendId를 Int로 디코딩, 실패 시 String으로 디코딩 후 변환
        if let id = try? container.decode(Int.self, forKey: .friendId) {
            self.friendId = id
        } else if let idString = try? container.decode(String.self, forKey: .friendId),
                  let id = Int(idString) {
            self.friendId = id
        } else {
            self.friendId = nil // 변환 실패 시 nil 할당
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
    let id: Int? // 요청에는 필요하지 않으므로 Optional
    let senderId: Int
    let receiverEmail: String? // 응답에는 필요하지 않으므로 Optional
    let senderName: String? // 요청에는 필요하지 않으므로 Optional
    let senderEmail: String? // 요청에는 필요하지 않으므로 Optional
    let status: String? // 요청에는 필요하지 않으므로 Optional

    // CodingKeys로 JSON 키와 Swift 속성 이름 매핑
    enum CodingKeys: String, CodingKey {
        case id = "requestId"
        case senderId
        case receiverEmail
        case senderName
        case senderEmail
        case status
    }
}
