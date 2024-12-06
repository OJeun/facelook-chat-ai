//
//  SignUpView.swift
//  iOS-Project
//
//  Created by Diane Choi on 2024-12-05.
//

import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewViewModel()
    let onSignUpSuccess: (Int, String, String) -> Void
    @Environment(\.dismiss) private var dismiss // navigate back to the login view

    var body: some View {
        VStack(spacing: 20) {
            // Header section
            HeaderView(
                title: "Register",
                subtitle: "Sign up, Today!",
                angle: 30,
                backColor: .blue,
                image: "facelook-white"
            )
            
            ZStack {
                // Background RoundedRectangle
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(UIColor.systemGray6))
                    .frame(maxWidth: 350, maxHeight: 300)
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
                    
                    // Name input
                    TextField("Name", text: $viewModel.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .frame(maxWidth: 300)
                    
                    // Sign-Up button
                    Button("Sign Up") {
                        viewModel.signUp { userID, userName, email in
                            onSignUpSuccess(userID, userName, email)
                            dismiss()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: 300)
                    
                    // Login
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.gray)
                        
                        NavigationLink(destination: LoginView(onLoginSuccess: { userID, userName in
                            print("Login successful! User ID: \(userID), User Name: \(userName)")
                            })) {
                            Text("Login")
                                .foregroundColor(.blue)
                                .fontWeight(.bold)
                        }
                    }
                
                    
                }
                .frame(maxWidth: .infinity)
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    SignUpView(onSignUpSuccess: { userID, userName, email in
        print("Sign Up successful! User ID: \(userID), User Name: \(userName), Email: \(email)")
    })
}
