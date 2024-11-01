//
//  ProfileView.swift
//  iOS-Project
//
//  Created by Aric Or on 2024-11-01.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack {
            Image(systemName: "person.circle")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("This is your Profile")
        }
        .padding()
    }
}

#Preview {
    ProfileView()
}
