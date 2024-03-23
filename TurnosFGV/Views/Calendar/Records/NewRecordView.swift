//
//  NewRecordView.swift
//  RegistroTurnos2
//
//  Created by Jose Antonio Mendoza on 17/2/24.
//

import SwiftData
import SwiftUI
import DateHelper

struct NewRecordView: View {
    // Environment properties
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Shifts Data Model
    let shiftGroups = ShiftsDataModel()
    
    // AppStorage properties
    @AppStorage("location") var location: String = ""

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
    @State private var isLicense: Bool = false
    @State private var isFreeLicense: Bool = false
    @State private var isPaidLicense: Bool = false
    @State private var isLeave: Bool = false
    @State private var isSickLeave: Bool = false
    @State private var isWorkAccident: Bool = false
    
    let date: Date
    
    var body: some View {
        VStack {
            CloseButton
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ShiftPicker
                    ShiftStartAndShiftEndText
                    ShiftExtraOptions
                }
            }
            
            SaveButton(text: "Guardar", color: selectedShift?.color ?? .appYellow, action: saveRecord)
                .disabled(selectedShift == nil)
                .opacity(selectedShift == nil ? 0.5 : 1)
        }
        .padding(15)
        .background(.appBackground)
        .task(id: date) {
            shiftsByLocation = shiftGroups.getActualShiftsByLocation(date)
        }
        .onChange(of: selectedShift) {
            if let selectedShift {
                saturation = selectedShift.saturation
                let shiftGroup = shiftGroups.shiftGroup(for: selectedShift.id)
                if shiftGroup?.location.rawValue != location {
                    isAllowance = true
                } else {
                    isAllowance = false
                }
            }
        }
    }
}

#Preview {
    NewRecordView(date: .init(fromString: "2024-02-01", format: .isoDate)!)
}

// MARK: - Extracted views
extension NewRecordView {
    @ViewBuilder
    var CloseButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.title)
                .tint(.red)
                .foregroundStyle(.appWhite.opacity(0.3))
        }
        .hSpacing(.leading)
        .padding(.bottom)
    }
    
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
                    if selectedShift == nil {
                        Text("Selecciona turno")
                    } else {
                        Text(selectedShift?.name ?? "")
                            .shiftTextModifier(color: selectedShift?.color ?? .appWhite)
                    }
                }
            }
            .frame(height: 50)
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
            LabeledContent("Dieta") {
                Toggle("", isOn: $isAllowance)
            }
            LabeledContent("Día festivo") {
                Toggle("", isOn: $isWorkedHoliday)
            }
            LabeledContent("Festivo especial") {
                Toggle("", isOn: $isSpecialWorkedHoliday)
            }
            LabeledContent("Práctica") {
                Toggle("", isOn: $isMentoring)
            }
            LabeledContent("SPP") {
                Toggle("", isOn: $isSPP)
            }
            LabeledContent("Licencia") {
                Toggle("", isOn: $isLicense.animation(.bouncy))
            }
            if isLicense {
                Group {
                    LabeledContent("Licencia sin sueldo") {
                        Toggle("", isOn: $isFreeLicense)
                    }
                    LabeledContent("Licencia con sueldo") {
                        Toggle("", isOn: $isPaidLicense)
                    }
                }
                .padding(.leading)
            }
            LabeledContent("Baja") {
                Toggle("", isOn: $isLeave.animation(.bouncy))
            }
            if isLeave {
                Group {
                    LabeledContent("Baja por enfermedad") {
                        Toggle("", isOn: $isSickLeave)
                    }
                    LabeledContent("Accidente laboral") {
                        Toggle("", isOn: $isWorkAccident)
                    }
                }
                .padding(.leading)
            }
        }
        .tint(selectedShift?.color ?? .appYellow)
        .groupBoxBackGroundStyle()
    }
}

// MARK: - Computed properties and functions
extension NewRecordView {
    var start: Date {
        guard let selectedShift else { return date }
        return date.adjust(for: .startOfDay)!.addingTimeInterval(selectedShift.startTime)
    }
    
    var end: Date {
        guard let selectedShift else { return date }
        return start.addingTimeInterval(selectedShift.duration)
    }
    
    var locations: [String] { Array(shiftsByLocation.keys.sorted(by: <)) }
    
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
