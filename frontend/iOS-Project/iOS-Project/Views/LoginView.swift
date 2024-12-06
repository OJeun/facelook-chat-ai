//
//  LoginView.swift
//  iOS-Project
//
//  Created by Aric Or on 2024-11-30.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewViewModel()
    let onLoginSuccess: (Int, String) -> Void // Updated to return both userID and userName

    var body: some View {
        NavigationView { // Wrap the entire view in a NavigationView
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
                        viewModel.login { userID, userName in
                            onLoginSuccess(userID, userName)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }

                // Add NavigationLink for Sign-Up
                NavigationLink(destination: SignUpView(onSignUpSuccess: { userID, userName, email in
                    print("Sign Up successful! User ID: \(userID), User Name: \(userName), Email: \(email)")
                })) {
                    Text("New User?")
                        .foregroundColor(.blue)
                }
                .padding(.top)

                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    LoginView(onLoginSuccess: { userID, userName in
        print("Login successful! User ID: \(userID), User Name: \(userName)")
    })
}
