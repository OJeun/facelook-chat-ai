//
//  Invitation.swift
//  diane-nogada
//
//  Created by Dianna on 2024-12-04.
//

import Foundation


struct Invitation: Identifiable, Codable {
    let id: Int
    let senderId: Int
    let senderName: String
    let groupName: String

    enum CodingKeys: String, CodingKey {
        case id = "invitationId"
        case senderId
        case senderName
        case groupName
    }
}

struct InvitationResponse: Codable {
    let invitations: [Invitation]
}
