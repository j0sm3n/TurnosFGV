//
//  HideViewModifier.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 27/3/24.
//

import SwiftUI

struct HideViewModifier: ViewModifier {
    let isHidden: Bool
    
    func body(content: Content) -> some View {
        if isHidden {
            EmptyView()
        } else {
            content
        }
    }
}

extension View {
    func hide(if isHidden: Bool) -> some View {
        ModifiedContent(content: self, modifier: HideViewModifier(isHidden: isHidden))
    }
}
