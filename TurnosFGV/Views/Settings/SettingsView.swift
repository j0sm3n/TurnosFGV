//
//  SettingsView.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 12/11/24.
//

import SwiftUI
import CloudStorage

struct SettingsView: View {
    @CloudStorage(Constants.prevYearHoursKey) var prevYearHours: Double = 0.0
    @CloudStorage(Constants.roleKey) var roleString: String = ""
    @CloudStorage(Constants.locationKey) var locationString: String = ""
    
    private let prevYear: Int = Date.now.year - 1

    var body: some View {
        NavigationStack {
            ScrollView {
                GroupBox {
                    LabeledContent("Categoría") {
                        Picker(roleString, selection: $roleString) {
                            ForEach(Role.allCases) { role in
                                Text(role.displayName)
                                    .tag(role.rawValue)
                            }
                        }
                    }
                    LabeledContent("Residencia") {
                        Picker(locationString, selection: $locationString) {
                            ForEach(Location.allCases) { location in
                                Text(location.displayName)
                                    .tag(location.rawValue)
                            }
                        }
                    }
                    LabeledContent("Saldo horas \(prevYear)") {
                        TextField("", value: $prevYearHours, format: .number)
                            .keyboardType(.numbersAndPunctuation)
                            .multilineTextAlignment(.trailing)
                            .padding(.trailing)
                            .foregroundStyle(prevYearHours < 0 ? .red : .green)
                            .bold()
                    }
                }
                .padding()
                .groupBoxBackGroundStyle()
            }
            .navigationTitle("Ajustes")
            .background(.appBackground)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
