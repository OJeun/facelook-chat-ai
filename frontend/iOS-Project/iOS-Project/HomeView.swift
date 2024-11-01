//
//  HomeView.swift
//  iOS-Project
//
//  Created by Aric Or on 2024-11-01.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            // Top Navigation Bar with Home, Search Bar, and Search Icon
            HStack {
                Spacer()
                Spacer()
                
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 36)
                    .foregroundColor(.gray.opacity(0.2))
                    .overlay(
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            Text("Search")
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                    )
                
                Spacer()
                
                Image(systemName: "magnifyingglass")
                    .imageScale(.large)
                    .padding(.trailing)
            }
            .padding(.vertical)
            
            // Main Content with Group Chat and Chat List Side by Side
            HStack(alignment: .top, spacing: 16) {
                
                // Vertical Scroll View for Group Chat Icons
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(0..<3) { _ in
                            Circle()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray.opacity(0.3))
                                .overlay(
                                    Text("group\nchat")
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                )
                        }
                        Circle()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray.opacity(0.3))
                            .overlay(Text("+").font(.largeTitle))
                    }
                }
                .padding(.leading)
                .padding(.top, 8)
                
                // Vertical Scroll View for Chat List
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(0..<5) { _ in
                            HStack(spacing: 16) {
                                // Profile image bubble
                                Circle()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.gray.opacity(0.3))
                                
                                // Chat preview container
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 60)
                                    .overlay(
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("User Name")
                                                .font(.headline)
                                            Text("Most recent history")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.leading, 8),
                                        alignment: .leading
                                    )
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .padding(.bottom, 8)
        }
    }
}

#Preview {
    HomeView()
}
