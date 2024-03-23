//
//  DisclosureGroupModifier.swift
//  RegistroTurnos2
//
//  Created by Jose Antonio Mendoza on 10/3/24.
//

import SwiftUI

struct DisclosureGroupModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .background(.appWhite.opacity(0.1).shadow(.inner(color: .white, radius: 9)), in: .rect(cornerRadius: 10))
            .padding(.horizontal)
    }
}

extension View {
    func disclosureGroupBackgroundStyle() -> some View {
        modifier(DisclosureGroupModifier())
    }
}
