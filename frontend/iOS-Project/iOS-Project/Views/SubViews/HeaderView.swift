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
    let image: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .foregroundColor(backColor)
                .rotationEffect(Angle(degrees: angle))
                .frame(height:600)
            
            VStack {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.top,40)
                    
                Text(title)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .bold()
                
                Text(subtitle)
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .padding(.top,10)
        }
        .frame(width: UIScreen.main.bounds.width * 3, height: 350)
        .offset(y: -50)
        .edgesIgnoringSafeArea(.top)
    }
}

#Preview {
    HeaderView(
        title: "Login",
        subtitle: "Access your account",
        angle: 15,
        backColor: .blue,
        image: "facelook-white"
    )
}
