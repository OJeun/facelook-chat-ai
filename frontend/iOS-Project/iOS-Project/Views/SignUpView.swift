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
        VStack {
            Text("Let's Register")
                .font(.title)
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
                
                TextField("Name", text: $viewModel.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .autocorrectionDisabled()

                Button("Sign Up") {
                    viewModel.signUp { userID, userName, email in
                        onSignUpSuccess(userID, userName, email)
                        dismiss()
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
    SignUpView(onSignUpSuccess: { userID, userName, email in
        print("Sign Up successful! User ID: \(userID), User Name: \(userName), Email: \(email)")
    })
}
