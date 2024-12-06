//
//  Group.swift
//  iOS-Project
//
//  Created by Fiona Wong on 2024-12-05.
//

import Foundation

// Align the UserGroup struct with the API response
struct UserGroup: Identifiable, Codable {
    let id: Int // Updated to Int for groupId
    let name: String

    enum CodingKeys: String, CodingKey {
        case id = "groupId"
        case name = "groupName"
    }
}

struct GroupListResponse: Codable {
    let groupList: [UserGroup]
}

struct CreateGroupResponse: Codable {
    let message: String
    let group: GroupDetails
}

struct GroupDetails: Codable {
    let lastChatId: String?
    let groupId: Int
    let groupName: String
}
