//
//  ContentViewViewModel.swift
//  iOS-Project
//
//  Created by Aric Or on 2024-11-30.
//

import Foundation
import SwiftUI

class ContentViewViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var userID: Int = 0
    @Published var userName: String = ""

    func checkLoginStatus() {
        // Safely fetch values from UserDefaults with type-specific methods
        let savedUserID = UserDefaults.standard.integer(forKey: "userID")
        let savedUserName = UserDefaults.standard.string(forKey: "userName") ?? ""

        if savedUserID != 0 && !savedUserName.isEmpty {
            isLoggedIn = true
            userID = savedUserID
            userName = savedUserName
        } else {
            // Reset state if no valid data is found
            isLoggedIn = false
            userID = 0
            userName = ""
        }
    }
}
