//
//  NewRecordView.swift
//  RegistroTurnos2
//
//  Created by Jose Antonio Mendoza on 17/2/24.
//

import CloudStorage
import SwiftData
import SwiftUI

struct NewRecordView: View {
    // Environment properties
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // CloudStorage properties
    @CloudStorage(Constants.locationKey) var location: String = ""

    // View properties
    @State private var shiftsByLocation: [String: [Shift]] = [:]
    @State private var selectedShift: Shift?

    // Draft record
    @State private var draft: WorkDay

    // Shifts Data Model
    let shiftGroups = ShiftsDataModel.shared

    // Selected date
    let date: Date

    init(date: Date) {
        self.date = date
        self._draft = State(initialValue: WorkDay(shift: "", startDate: date, endDate: date))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                shiftPicker
                shiftStartAndEnd
                shiftExtraOptions
            }
        }
        .padding(15)
        .background(.appBackground)
        .task {
            shiftsByLocation = shiftGroups.getActualShiftsByLocation(date)
        }
        .onChange(of: selectedShift) {
            if let selectedShift {
                draft.shift = selectedShift.name
                draft.startDate = date.startOfDay.addingTimeInterval(selectedShift.startTime)
                draft.endDate = draft.startDate.addingTimeInterval(selectedShift.duration)
                draft.saturation = selectedShift.saturation
                draft.isAllowance = !shiftsByLocation.isFromUserLocation(selectedShift, userLocation: location)
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
    private var shiftPicker: some View {
        ShiftPickerGroupBox(shiftsByLocation: shiftsByLocation, selectedShift: $selectedShift)
    }

    private var shiftStartAndEnd: some View {
        GroupBox {
            LabeledContent("Inicio") {
                Text(draft.startDate.toString("dd/MM/yyyy HH:mm"))
                    .monospaced()
            }
            LabeledContent("Fin") {
                Text(draft.endDate.toString("dd/MM/yyyy HH:mm"))
                    .monospaced()
            }
        }
        .groupBoxBackGroundStyle()
    }

    private var shiftExtraOptions: some View {
        GroupBox {
            WorkDayTogglesSection(workDay: draft)
        }
        .tint(selectedShift?.color ?? .appYellow)
        .groupBoxBackGroundStyle()
    }

    // MARK: - Functions
    private func saveRecord() {
        guard selectedShift != nil else { return }
        modelContext.insert(draft)
        dismiss()
    }
}
