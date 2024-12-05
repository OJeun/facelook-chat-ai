//
//  Invitation.swift
//  diane-nogada
//
//  Created by Dianna on 2024-12-04.
//

import Foundation


struct Invitation: Codable {
    let invitationId: Int
    let senderId: Int
    let senderName: String
    let groupName: String
}
