//
//  WorkDayTogglesSection.swift
//  TurnosFGV
//

import SwiftUI

struct WorkDayTogglesSection: View {
    @Bindable var workDay: WorkDay
    @State private var isLicense: Bool
    @State private var isSick: Bool

    init(workDay: WorkDay) {
        self.workDay = workDay
        self._isLicense = State(initialValue: workDay.isFreeLicense || workDay.isPaidLicense)
        self._isSick = State(initialValue: workDay.isSickLeave || workDay.isWorkAccident)
    }

    var body: some View {
        ToggleRow("Dieta", isOn: $workDay.isAllowance)
        ToggleRow("Festivo", isOn: $workDay.isWorkedHoliday)
        ToggleRow("Festivo especial", isOn: $workDay.isSpecialWorkedHoliday)
        ToggleRow("Práctica", isOn: $workDay.isMentoring)
        ToggleRow("SPP", isOn: $workDay.isSPP)
        DisclosureGroup("Licencia", isExpanded: $isLicense) {
            Group {
                ToggleRow("Sin sueldo", isOn: $workDay.isFreeLicense)
                ToggleRow("Con sueldo", isOn: $workDay.isPaidLicense)
            }
            .padding(.leading)
            .padding(.trailing, 2)
        }
        .foregroundStyle(.white)
        .onChange(of: workDay.isFreeLicense) { if workDay.isFreeLicense { isLicense = true } }
        .onChange(of: workDay.isPaidLicense) { if workDay.isPaidLicense { isLicense = true } }
        DisclosureGroup("Baja", isExpanded: $isSick) {
            Group {
                ToggleRow("Por enfermedad", isOn: $workDay.isSickLeave)
                ToggleRow("Accidente laboral", isOn: $workDay.isWorkAccident)
            }
            .padding(.leading)
            .padding(.trailing, 2)
        }
        .foregroundStyle(.white)
        .onChange(of: workDay.isSickLeave) { if workDay.isSickLeave { isSick = true } }
        .onChange(of: workDay.isWorkAccident) { if workDay.isWorkAccident { isSick = true } }
    }
}
