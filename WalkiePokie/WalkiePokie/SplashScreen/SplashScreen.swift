//
//  SplashScreen.swift
//  WalkiePokie
//
//  Created by Vatsal Vipulkumar Patel on 7/21/23.
//

import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    @State private var isWalking = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive{
            ContentView()
        } else {
            ZStack {
                Color(hex: 0x3A434E)
                    .ignoresSafeArea()
                VStack {
                    Image("Logo NEw")
                        .resizable()
                        .frame(width: 70, height: 110)
                        .rotationEffect(.degrees(isWalking ? 20 : -20))
                        .animation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isWalking)
                        .onAppear {
                            self.isWalking.toggle()
                        }
                    HStack{
                        Text("Walkie")
                            .font(.custom(FontManager.Montserrat.bold, size: 40).weight(.black))
                            .textCase(.uppercase)
                            .bold()
                            .foregroundColor(.white)
                        Text("Pokie")
                            .font(.custom(FontManager.Montserrat.bold, size: 40).weight(.black))
                            .textCase(.uppercase)
                            .bold()
                            .foregroundColor(Color(hex: 0xB3CFF2))
                    }.padding(.bottom, 20)
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 0.9
                        self.opacity = 1.00
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
        
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
