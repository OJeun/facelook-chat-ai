//
//  LogoutButtonView.swift
//  iOS-Project
//
//  Created by Fiona Wong on 2024-12-06.
//

import SwiftUI

struct LogoutButtonView: View {
    @ObservedObject var viewModel = ProfileViewViewModel()
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        Button(action: {
            viewModel.logout()
            isLoggedIn = false
        }) {
            Text("Logout")
                .bold()
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
        }
    }
}

#Preview {
    LogoutButtonView(viewModel: ProfileViewViewModel(), isLoggedIn: .constant(false))
}
