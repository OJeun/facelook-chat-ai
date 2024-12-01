//
//  LoginResponse.swift
//  iOS-Project
//
//  Created by Aric Or on 2024-11-30.
//

import Foundation

struct LoginResponse: Codable {
    let token: String
    let message: String
    let user: User
}

struct User: Codable {
    let userId: Int
    let email: String
    let name: String
    let password: String
    let achievementPoint: Int
}
