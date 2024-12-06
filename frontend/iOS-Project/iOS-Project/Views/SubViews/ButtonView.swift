//
//  ButtonView.swift
//  iOS-Project
//
//  Created by Fiona Wong on 2024-12-05.
//

import SwiftUI

struct ButtonView: View {
    let title: String
    let backgroundColor: Color = .white
    let foregroundColor: Color = .gray
    let borderColor: Color = .gray
    let action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            Text(title)
                .bold()
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(borderColor, lineWidth: 5)
                )
        }
    }
}

#Preview {
    ButtonView(title: "Button")
}
