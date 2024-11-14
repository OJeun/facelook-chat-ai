//
//  LeaderboardView.swift
//  iOS-Project
//
//  Created by Aric Or on 2024-11-01.
//

import SwiftUI

struct LeaderboardView: View {
    var body: some View {
        VStack {
            Image(systemName: "chart.bar")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Leaderboard Rankings")
        }
        .padding()
    }
}

#Preview {
    LeaderboardView()
}
