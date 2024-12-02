//
//  ContentViewViewModel.swift
//  iOS-Project
//
//  Created by Aric Or on 2024-11-30.
//

import Foundation
import SwiftUI

class ContentViewViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var userID: Int = 0

    func checkLoginStatus() {
        if let savedUserID = UserDefaults.standard.value(forKey: "userID") as? Int {
            isLoggedIn = true
            userID = savedUserID
        } else {
            isLoggedIn = false
            userID = 0
        }
    }
}
