//
//  OnboardView.swift
//  OnboardTest
//
//  Created by Jose Antonio Mendoza on 30/1/24.
//

import SwiftUI

struct OnboardStepView<T: PickerEnum>: View {
    var id = UUID()
    let systemImageName: String
    let title: String
    let description: String
    @Binding var item: T

    var body: some View {
        ScrollView {
            VStack {
                Image(systemName: systemImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .foregroundStyle(.appPurple)
                    .padding(.bottom, 50)
                
                Text(title)
                    .font(.title.bold())
                
                Text(description)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.appWhite)
                    .padding(.vertical, 20)
                
                CustomPicker(selection: $item)
            }
            .padding(.horizontal, 40)
            .padding(.top, 100)
        }
    }
}

//#Preview {
//    OnboardView<Category>(
//        systemImageName: "person.fill.viewfinder",
//        title: "Categoría",
//        description: "Selecciona tu categoría para poder mostrar correctamente qué turnos puedes hacer.",
//        item: .constant(Category.usi)
//    )
//}
