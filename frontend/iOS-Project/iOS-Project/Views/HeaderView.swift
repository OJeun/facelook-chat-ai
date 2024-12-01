//
//  HeaderView.swift
//  iOS-Project
//
//  Created by Aric Or on 2024-11-30.
//

import SwiftUI

struct HeaderView: View {
    let title: String
    let subtitle: String
    let angle: Double
    let backColor: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .foregroundColor(backColor)
                .rotationEffect(Angle(degrees: angle))
            
            VStack {
                Text(title)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .bold()
                
                Text(subtitle)
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .padding(.top, 80)
        }
        .frame(width: UIScreen.main.bounds.width * 3, height: 350)
        .offset(y: -150)
    }
}

#Preview {
    HeaderView(
        title: "Login",
        subtitle: "Access your account",
        angle: 15,
        backColor: .blue
    )
}
