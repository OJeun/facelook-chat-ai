//
//  UserAchievement.swift
//  iOS-Project
//
//  Created by Aric Or on 2024-12-05.
//

import Foundation

struct UserAchievement: Identifiable, Decodable {
    let id: Int
    let name: String
    let achievementPoint: Int

    enum CodingKeys: String, CodingKey {
        case id = "userId"
        case name
        case achievementPoint
    }
}
