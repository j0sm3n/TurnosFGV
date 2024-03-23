//
//  GroupBoxBackgroundModifier.swift
//  RegistroTurnos2
//
//  Created by Jose Antonio Mendoza on 1/3/24.
//

import SwiftUI

struct GroupBoxBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .backgroundStyle(.appWhite.opacity(0.1).shadow(.inner(color: .white, radius: 9)))
    }
}

extension View {
    func groupBoxBackGroundStyle() -> some View {
        modifier(GroupBoxBackgroundModifier())
    }
}
