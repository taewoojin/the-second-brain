//
//  AnimatingFont.swift
//  ProSwiftUI
//
//  Created by Theo on 1/20/26.
//

import SwiftUI

struct AnimatableFontModifier: ViewModifier, Animatable {
    var size: Double

    var animatableData: Double {
        get { size }
        set { size = newValue }
    }

    func body(content: Content) -> some View {
        content
            .font(.system(size: size))
    }
}

extension View {
    func animatableFont(size: Double) -> some View {
        self.modifier(AnimatableFontModifier(size: size))
    }
}

struct AnimatingFont: View {
    @State private var scaleUp = false
    
    var body: some View {
        Text("Hello, World!")
            .animatableFont(size: scaleUp ? 56 : 24)
            .onTapGesture {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                    scaleUp.toggle()
                }
            }
    }
}

#Preview {
    AnimatingFont()
}
