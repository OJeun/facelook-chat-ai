//
//  ProfileView.swift
//  iOS-Project
//
//  Created by Aric Or on 2024-11-01.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Profile Image
            Image(systemName: "person.crop.circle")
                .resizable()
                          .aspectRatio(contentMode: .fill)
                          .frame(width: 100, height: 100)
                          .foregroundColor(.gray)
            
            // Name
            Text("Alex Morgan")
                .font(.system(size: 24, weight: .bold))
            
            // Bio
            Text("Email Score: 1000")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Buttons
            // Edit profile
            HStack(spacing: 16) {
                Button(action: {
                    print("Edit Profile tapped!")
                }) {
                    Text("Edit Profile")
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            //friend requst
                Button(action: {
                    print("Message tapped!")
                }) {
                    Text("Friend Request")
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            
            Text("References").font(Font.system(size: 25, weight: .bold))
        }
        .padding()
    }
}
#Preview {
    ProfileView()
}
