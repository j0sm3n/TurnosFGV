//
//  ShiftTextModifier.swift
//  RegistroTurnos2
//
//  Created by Jose Antonio Mendoza on 1/3/24.
//

import SwiftUI

struct ShiftTextModifier: ViewModifier {
    let size: CGFloat
    let color: Color

    func body(content: Content) -> some View {
        content
            .font(.system(size: size))
            .fontWeight(.bold)
            .fontWidth(.condensed)
            .foregroundStyle(color)
    }
}

extension View {
    func shiftTextModifier(size: CGFloat = 32, color: Color = .white) -> some View {
        modifier(ShiftTextModifier(size: size, color: color))
    }
}
