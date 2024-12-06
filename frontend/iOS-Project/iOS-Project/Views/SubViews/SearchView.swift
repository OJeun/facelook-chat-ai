//
//  SearchView.swift
//  iOS-Project
//
//  Created by Fiona Wong on 2024-12-05.
//

import SwiftUI

struct SearchView: View {
    var body: some View {
        HStack {
            Spacer()
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 40)
                .foregroundColor(.white.opacity(0.3))
                .overlay(
                    HStack {
                        Text("Search")
                            .foregroundColor(.white)
                    }
                )
            Spacer()
            Image(systemName: "magnifyingglass")
                .imageScale(.large)
                .padding(.trailing)
                .foregroundColor(.white)
        }
        .padding(.top, 5)
        .offset(y:-35)
        .padding(.vertical)
        .padding(.horizontal, 20)
    }
}


#Preview {
    SearchView()
}
