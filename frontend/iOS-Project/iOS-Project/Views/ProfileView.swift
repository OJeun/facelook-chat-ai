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
                    // Name
                    Text(user.name)
                        .font(.system(size: 24, weight: .bold))
                    
                    Text("Email: \(user.email)")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("Achievement Points: \(user.achievementPoint)")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    ProgressView("Loading...")
                        .padding()
                }

                // Buttons
                HStack(spacing: 16) {
                    NavigationLink(destination: EditProfileView()) {
                        Text("Edit Profile")
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    NavigationLink(destination: FriendRequestsView()) {
                        Text("Friend Request")
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }

                    NavigationLink(destination: AddFriendView()) {
                        Text("Add Friend")
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                Text("References").font(Font.system(size: 25, weight: .bold))
                
                Spacer()

                // Logout Button
                Button(action: {
                    viewModel.logout()
                    isLoggedIn = false
                }) {
                    Text("Logout")
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
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
