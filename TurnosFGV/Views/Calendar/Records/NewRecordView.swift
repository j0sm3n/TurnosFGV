//
//  NewRecordView.swift
//  RegistroTurnos2
//
//  Created by Jose Antonio Mendoza on 17/2/24.
//

import CloudStorage
import DateHelper
import SwiftData
import SwiftUI

struct NewRecordView: View {
    // Environment properties
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // CloudStorage properties
    @CloudStorage("location") var location: String = ""
    
    // View properties
    @State private var shiftsByLocation: [String: [Shift]] = [:]
    @State private var selectedShift: Shift?
    
    // New record properties
    @State private var saturation: Double? = nil
    @State private var extraTime: Int = 0
    @State private var isAllowance: Bool = false
    @State private var isWorkedHoliday: Bool = false
    @State private var isSpecialWorkedHoliday: Bool = false
    @State private var isMentoring: Bool = false
    @State private var isSPP: Bool = false
    @State private var isFreeLicense: Bool = false
    @State private var isPaidLicense: Bool = false
    @State private var isSickLeave: Bool = false
    @State private var isWorkAccident: Bool = false
    
    // Shifts Data Model
    let shiftGroups = ShiftsDataModel.shared
    
    // Selected date
    let date: Date
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ShiftPicker
                ShiftStartAndShiftEndText
                ShiftExtraOptions
            }
        }
        .padding(15)
        .background(.appBackground)
        .task {
            shiftsByLocation = shiftGroups.getActualShiftsByLocation(date)
        }
        .onChange(of: selectedShift) {
            if let selectedShift {
                saturation = selectedShift.saturation
                isAllowance = !shiftsByLocation.isFromUserLocation(selectedShift, userLocation: location)
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .cancel) {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm) {
                    saveRecord()
                }
                .tint(selectedShift?.color ?? .clear)
                .disabled(selectedShift == nil)
            }
        }
    }
}

#Preview {
    NavigationStack {
        NewRecordView(date: .now)
            .modelContainer(for: WorkDay.self, inMemory: true)
    }
}

extension NewRecordView {
    // MARK: - Extracted views
    @ViewBuilder
    var ShiftPicker: some View {
        GroupBox {
            LabeledContent("Turno") {
                Menu {
                    ForEach(locations, id: \.self) { location in
                        Picker(location, selection: $selectedShift) {
                            ForEach(shiftsOf(location), id: \.self) { shift in
                                Text(shift.name).tag(shift as Shift?)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                } label: {
                    Text(selectedShift?.name ?? "Selecciona turno")
                        .shiftTextModifier(color: selectedShift?.color ?? .white.opacity(0.6))
                }
            }
        }
        .groupBoxBackGroundStyle()
    }
    
    @ViewBuilder
    var ShiftStartAndShiftEndText: some View {
        GroupBox {
            LabeledContent("Inicio") {
                Text(start.toString(format: .custom("dd/MM/yyyy HH:mm"))!)
                    .monospaced()
            }
            LabeledContent("Fin") {
                Text(end.toString(format: .custom("dd/MM/yyyy HH:mm"))!)
                    .monospaced()
            }
        }
        .groupBoxBackGroundStyle()
    }
    
    @ViewBuilder
    var ShiftExtraOptions: some View {
        GroupBox {
            ToggleRow("Dieta", isOn: $isAllowance)
            ToggleRow("Día festivo", isOn: $isWorkedHoliday)
            ToggleRow("Festivo especial", isOn: $isSpecialWorkedHoliday)
            ToggleRow("Práctica", isOn: $isMentoring)
            ToggleRow("SPP", isOn: $isSPP)

            DisclosureGroup("Licencia") {
                Group {
                    ToggleRow("Sin sueldo", isOn: $isFreeLicense)
                    ToggleRow("Con sueldo", isOn: $isPaidLicense)
                }
                .padding(.leading)
                .padding(.trailing, 2)
            }
            .foregroundStyle(.white)

            DisclosureGroup("Baja") {
                Group {
                    ToggleRow("Por enfermedad", isOn: $isSickLeave)
                    ToggleRow("Accidente laboral", isOn: $isWorkAccident)
                }
                .padding(.leading)
                .padding(.trailing, 2)
            }
            .foregroundStyle(.white)
        }
        .tint(selectedShift?.color ?? .appYellow)
        .groupBoxBackGroundStyle()
    }
    
    // MARK: - Computed properties and functions
    var start: Date {
        guard let selectedShift else { return date }
        return date.adjust(for: .startOfDay)!.addingTimeInterval(selectedShift.startTime)
    }
    
    var end: Date {
        guard let selectedShift else { return date }
        return start.addingTimeInterval(selectedShift.duration)
    }
    
    var locations: [String] { shiftsByLocation.keys.sorted(by: <) }
    
    private func saveRecord() {
        guard let selectedShift else { return }
        let workDay = WorkDay(
            shift: selectedShift.name,
            startDate: start,
            endDate: end,
            saturation: saturation,
            extraTime: extraTime,
            isAllowance: isAllowance,
            isFreeLicense: isFreeLicense,
            isWorkedHoliday: isWorkedHoliday,
            isSpecialWorkedHoliday: isSpecialWorkedHoliday,
            isMentoring: isMentoring,
            isPaidLicense: isPaidLicense,
            isSickLeave: isSickLeave,
            isWorkAccident: isWorkAccident,
            isSPP: isSPP
        )
        modelContext.insert(workDay)
        dismiss()
    }
    
    private func shiftsOf(_ location: String) -> [Shift] {
        shiftsByLocation[location]?.sorted() ?? []
    }

}
