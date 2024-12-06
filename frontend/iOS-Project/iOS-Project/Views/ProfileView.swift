//
//  ProfileView.swift
//  iOS-Project
//
//  Created by Aric Or on 2024-11-01.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewViewModel()
    @Binding var isLoggedIn: Bool

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Profile Image
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
                
                if let user = viewModel.user {
                    VStack {
                        HeaderView(
                            title: "\(user.name)",
                            subtitle: "\(user.email)",
                            angle: -30,
                            backColor: .blue,
                            image: "logo"
                        )
                    }
                        
                Text("Achievement Points: \(user.achievementPoint)")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .bold()
                } else if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    ProgressView("Loading...")
                        .padding()
                }

                // Buttons
                HStack(spacing: 15) {
                    NavigationLink(destination: EditProfileView()) {
                        ButtonView(title: "Edit Profile")
                    }

                    NavigationLink(destination: FriendRequestsView()) {
                        ButtonView(title: "Friend Request")
                    }

                    NavigationLink(destination: AddFriendView()) {
                        ButtonView(title: "Add Friend")
                    }
                }
                .padding(.horizontal)
                
                Spacer()

                // Logout Button
                LogoutButtonView(viewModel: viewModel, isLoggedIn: $isLoggedIn)
            }
            .padding()
            .onAppear {
                viewModel.fetchUserProfile()
            }
        }
    }
}

#Preview {
    ProfileView(isLoggedIn: .constant(true))
}

