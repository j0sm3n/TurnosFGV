//
//  DisclosureGroupLabelModifier.swift
//  RegistroTurnos2
//
//  Created by Jose Antonio Mendoza on 10/3/24.
//

import SwiftUI

struct DisclosureGroupLabelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title2)
            .foregroundStyle(.appWhite)
            .padding(.vertical, 13)
    }
}

extension View {
    func disclosureGroupLabelStyle() -> some View {
        modifier(DisclosureGroupLabelModifier())
    }
}
