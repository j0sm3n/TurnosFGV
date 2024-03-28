//
//  Onboard.swift
//  RegistroTurnos3
//
//  Created by Jose Antonio Mendoza on 31/1/24.
//

import CloudStorage
import SwiftUI

struct OnboardView: View {
    @CloudStorage("role") var roleString: String = ""
    @CloudStorage("location") var locationString: String = ""
    
    @State private var role: Role = .maquinista
    @State private var location: Location = .benidorm
    
    @State private var selectedView = 1
    let maxNumberOfScreens = 2
    
    @CloudStorage(Constants.currentOnboardingVersion) private var hasSeenOnboardingView = false

    var body: some View {
        VStack {
            TabView(selection: $selectedView) {
                OnboardStepView<Role>(
                    systemImageName: "person.fill.viewfinder",
                    title: "Categoría",
                    description: "Selecciona tu categoría para poder mostrar correctamente qué turnos puedes hacer.",
                    item: $role
                )
                .tag(1)
                
                OnboardStepView<Location>(
                    systemImageName: "building.2",
                    title: "Residencia",
                    description: "Selecciona tu residencia para poder marcar con dieta cuando hagas un turno fuera de tu residencia",
                    item: $location
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            Button {
                if selectedView == maxNumberOfScreens {
                    roleString = role.rawValue
                    locationString = location.rawValue
                    hasSeenOnboardingView = true
                } else {
                    selectedView += 1
                }
            } label: {
                Text(selectedView ==  maxNumberOfScreens ? "Guardar" : "Siguiente")
            }
            .tint(.appPurple)
            .buttonStyle(.borderedProminent)
            .padding(.vertical)
        }
        .background(.appBackground)
    }
}

#Preview {
    OnboardView()
}
