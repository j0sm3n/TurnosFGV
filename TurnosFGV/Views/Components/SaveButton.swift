//
//  SaveButton.swift
//  RegistroTurnos2
//
//  Created by Jose Antonio Mendoza on 25/2/24.
//

import SwiftUI

struct SaveButton: View {
    let text: String
    let color: Color
    let action: () -> Void
    
    init(text: String, color: Color, action: @escaping () -> Void) {
        self.text = text
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action, label: {
            Text(text)
                .font(.title3)
                .fontWeight(.semibold)
                .textScale(.secondary)
                .foregroundStyle(color.adaptedTextColor())
                .hSpacing(.center)
                .padding(.vertical, 12)
                .background(color.gradient.shadow(.inner(color: .appWhite, radius: 2)), in: .rect(cornerRadius: 10))
            
        })
    }
    
}

#Preview {
    VStack {
        SaveButton(text: "Botón", color: .appYellow, action: {})
        SaveButton(text: "Botón", color: .appOrange, action: {})
        SaveButton(text: "Botón", color: .appBlue, action: {})
    }
}
