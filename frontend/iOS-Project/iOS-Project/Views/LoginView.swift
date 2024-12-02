//
//  LoginView.swift
//  iOS-Project
//
//  Created by Aric Or on 2024-11-30.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewViewModel()
    let onLoginSuccess: (Int) -> Void

    var body: some View {
        VStack {
            HeaderView(
                title: "Login",
                subtitle: "Access your account",
                angle: 15,
                backColor: .blue
            )

            Form {
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                }

                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .autocorrectionDisabled()

                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Log In") {
                    viewModel.login { userID in
                        onLoginSuccess(userID)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    LoginView(onLoginSuccess: { userID in
        print("Login successful! User ID: \(userID)")
    })
}
