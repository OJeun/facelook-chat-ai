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

    func checkLoginStatus() {
        // Assume the user is logged out by default
        isLoggedIn = false
    }
}
