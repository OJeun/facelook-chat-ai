//
//  ButtonView.swift
//  iOS-Project
//
//  Created by Fiona Wong on 2024-12-05.
//

import SwiftUI

struct ButtonView: View {
    var title: String

    var body: some View {
        Text(title)
            .bold()
            .frame(maxWidth: .infinity, maxHeight: 50)
            .background(Color.white)
            .foregroundColor(.gray)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 2)
            )
    }
}

#Preview {
    ButtonView(title: "Sample Button")
}
