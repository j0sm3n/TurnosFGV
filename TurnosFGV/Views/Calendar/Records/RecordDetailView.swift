//
//  RecordDetailView.swift
//  RegistroTurnos2
//
//  Created by Jose Antonio Mendoza on 16/2/24.
//

import CloudStorage
import SwiftData
import SwiftUI

struct RecordDetailView: View {
    // Environment properties
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // CloudStorage properties
    @CloudStorage(Constants.locationKey) var location: String = ""

    // View properties
    @State private var showDeleteAlert: Bool = false
    @State private var shiftsByLocation: [String: [Shift]] = [:]
    @FocusState private var isFocused: Bool

    // Update record properties
    @State private var shift: Shift?
    @State private var updateWorkDay: WorkDay

    // Record to edit
    @Bindable var workDay: WorkDay

    // Shifts Data Model
    let shiftGroups = ShiftsDataModel.shared

    init(workDay: WorkDay) {
        self.workDay = workDay
        self.updateWorkDay = workDay.copy()
    }

    var body: some View {
        NavigationStack {
            VStack {
                dateHeader
                ScrollView {
                    VStack(spacing: 20) {
                        shiftPicker
                        shiftStartAndEnd
                        shiftExtraOptions
                    }
                }
                .scrollIndicators(.hidden)
            }
            .padding()
            .background(.appBackground)
            .task {
                shiftsByLocation = shiftGroups.getActualShiftsByLocation(workDay.startDate)
                shift = shifts.first(where: { $0.name == updateWorkDay.shift })
            }
            .toolbar {
                ToolbarItem(placement: .destructiveAction) {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    }
                    .tint(.red)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        updateRecord()
                    }
                    .tint(updateWorkDay.color)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }
            }
            .alert("Borrar turno \(shift?.name ?? "")", isPresented: $showDeleteAlert) {
                Button("Borrar", role: .destructive, action: deleteRecord)
                Button("Cancelar", role: .cancel, action: {})
            } message: {
                Text("¿Seguro que quieres borrar el turno del día \(updateWorkDay.startDate.toString("dd MMM"))?")
            }
        }
    }
}

#Preview {
    @Previewable let container = try! ModelContainer(for: WorkDay.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    @Previewable let workDay = WorkDay(
        shift: "1",
        startDate: Date(isoDateTime: "2024-02-04T05:27:00+01:00")!,
        endDate: Date(isoDateTime: "2024-02-04T13:36:00+01:00")!,
        saturation: 72.1,
        extraTime: 8,
        isAllowance: true
    )

    container.mainContext.insert(workDay)

    return RecordDetailView(workDay: workDay)
        .modelContainer(container)
}

extension RecordDetailView {
    // MARK: - Extracted views
    private var dateHeader: some View {
        VStack {
            Text(updateWorkDay.startDate.formatted(date: .complete, time: .omitted))
                .font(.title.bold())
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)
                .padding(.bottom)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var shiftPicker: some View {
        ShiftPickerGroupBox(shiftsByLocation: shiftsByLocation, selectedShift: $shift)
            .onChange(of: shift, initial: false) { shiftChanged() }
    }

    private var shiftStartAndEnd: some View {
        GroupBox {
            LabeledContent("Inicio de jornada") {
                Text(updateWorkDay.startDate, style: .time)
            }

            LabeledContent("Fin de jornada") {
                Text(updateWorkDay.endDate, style: .time)
            }
        }
        .groupBoxBackGroundStyle()
    }

    private var shiftExtraOptions: some View {
        GroupBox {
            LabeledContent("Duración", value: updateWorkDay.workingHours)

            LabeledContent("Saturación", value: updateWorkDay.saturation ?? 0, format: .number)

            LabeledContent("Nocturnidad", value: updateWorkDay.nightTimeString)

            LabeledContent("Exceso de jornada") {
                HStack {
                    TextField("Minutos", value: $updateWorkDay.extraTime, formatter: NumberFormatter())
                        .frame(width: 80)
                        .multilineTextAlignment(.trailing)
                        .focused($isFocused)
                    Text("min")
                }
            }
            .contentShape(.rect)
            .onTapGesture {
                isFocused = true
            }

            WorkDayTogglesSection(workDay: updateWorkDay)
        }
        .groupBoxBackGroundStyle()
        .tint(updateWorkDay.color)
    }

    // MARK: - Computed properties and functions
    private var locations: [String] {
        shiftsByLocation.keys.sorted(by: <)
    }

    private var shifts: [Shift] {
        locations.flatMap { shiftsByLocation[$0] ?? [] }
    }

    private func updateRecord() {
        workDay.shift = updateWorkDay.shift
        workDay.startDate = updateWorkDay.startDate
        workDay.endDate = updateWorkDay.endDate
        workDay.saturation = updateWorkDay.saturation
        workDay.extraTime = updateWorkDay.extraTime
        workDay.isAllowance = updateWorkDay.isAllowance
        workDay.isFreeLicense = updateWorkDay.isFreeLicense
        workDay.isWorkedHoliday = updateWorkDay.isWorkedHoliday
        workDay.isSpecialWorkedHoliday = updateWorkDay.isSpecialWorkedHoliday
        workDay.isMentoring = updateWorkDay.isMentoring
        workDay.isPaidLicense = updateWorkDay.isPaidLicense
        workDay.isSickLeave = updateWorkDay.isSickLeave
        workDay.isWorkAccident = updateWorkDay.isWorkAccident
        workDay.isSPP = updateWorkDay.isSPP

        dismiss()
    }

    private func deleteRecord() {
        modelContext.delete(workDay)
        dismiss()
    }

    private func shiftChanged() {
        guard let shift, updateWorkDay.shift != shift.name else { return }

        updateWorkDay.shift = shift.name
        updateWorkDay.startDate = updateWorkDay.startDate.startOfDay.addingTimeInterval(shift.startTime)
        updateWorkDay.endDate = updateWorkDay.startDate.addingTimeInterval(shift.duration)
        updateWorkDay.saturation = shift.saturation
        updateWorkDay.extraTime = 0
        updateWorkDay.isAllowance = !shiftsByLocation.isFromUserLocation(shift, userLocation: location)
    }
}
