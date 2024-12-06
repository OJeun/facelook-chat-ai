//
//  LoginView.swift
//  iOS-Project
//
//  Created by Aric Or on 2024-11-30.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewViewModel()
    let onLoginSuccess: (Int, String) -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header section
                HeaderView(
                    title: "Login",
                    subtitle: "Access your account",
                    angle: 15,
                    backColor: .blue
                )

                // Form
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(UIColor.systemGray6))
                        .frame(maxWidth: 350, minHeight: 200)
                        .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 3)

                    VStack(alignment: .leading, spacing: 15) {
                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .foregroundColor(.red)
                        }
                        
                        // Email input
                        TextField("Email", text: $viewModel.email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .frame(maxWidth: 300)
                        
                        // Password input
                        SecureField("Password", text: $viewModel.password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 300)
                        
                        // Login button
                        Button("Log In") {
                            viewModel.login { userID, userName in
                                onLoginSuccess(userID, userName)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: 300)
                    }
                    .frame(maxWidth: .infinity)
                }

                // Sign-up prompt
                VStack {
                    Text("Don't have an account?")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    NavigationLink(destination: SignUpView(onSignUpSuccess: { userID, userName, email in
                        print("Sign Up successful! User ID: \(userID), User Name: \(userName), Email: \(email)")
                    })) {
                        Text("Sign Up")
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                    }
                }

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
