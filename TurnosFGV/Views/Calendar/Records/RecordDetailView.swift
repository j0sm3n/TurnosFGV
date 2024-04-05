//
//  RecordDetailView.swift
//  RegistroTurnos2
//
//  Created by Jose Antonio Mendoza on 16/2/24.
//

import CloudStorage
import DateHelper
import SwiftData
import SwiftUI

struct RecordDetailView: View {
    // Environment properties
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // CloudStorage properties
    @CloudStorage("location") var location: String = ""
    
    // View properties
    @State private var isLicense: Bool = false
    @State private var isSick: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var shiftsByLocation: [String: [Shift]] = [:]
    
    // Update record properties
    @State private var shift: Shift?
    @State private var updateWorkDay: WorkDay
    
    // Record to edit
    @Bindable var workDay: WorkDay
    
    // Shifts Data Model
    let shiftGroups = ShiftsDataModel()
    
    init(workDay: WorkDay) {
        self.workDay = workDay
        self.updateWorkDay = WorkDay(
            shift: workDay.shift,
            startDate: workDay.startDate,
            endDate: workDay.endDate,
            saturation: workDay.saturation,
            extraTime: workDay.extraTime,
            isAllowance: workDay.isAllowance,
            isFreeLicense: workDay.isFreeLicense,
            isWorkedHoliday: workDay.isWorkedHoliday,
            isSpecialWorkedHoliday: workDay.isSpecialWorkedHoliday,
            isMentoring: workDay.isMentoring,
            isPaidLicense: workDay.isPaidLicense,
            isSickLeave: workDay.isSickLeave,
            isWorkAccident: workDay.isWorkAccident,
            isSPP: workDay.isSPP
        )
    }
    
    var body: some View {
        VStack {
            DateHeader
            
            ScrollView {
                VStack(spacing: 20) {
                    ShiftPicker
                    ShiftStartAndEnd
                    ShiftExtraOptions
                }
            }
            .scrollIndicators(.hidden)
            
            SaveButton(text: "Actualizar", color: updateWorkDay.color, action: updateRecord)
        }
        .padding()
        .background(.appBackground)
        .task {
            shiftsByLocation = shiftGroups.getActualShiftsByLocation(workDay.startDate)
            shift = shifts.first(where: { $0.name == updateWorkDay.shift })
        }
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button("Borrar", role: .destructive) {
                    showDeleteAlert = true
                }
                .tint(.red)
            }
        }
        .alert("Borrar turno \(shift?.name ?? "")", isPresented: $showDeleteAlert) {
            Button("Borrar", role: .destructive, action: deleteRecord)
            Button("Cancelar", role: .cancel, action: {})
        } message: {
            Text("¿Seguro que quieres borrar el turno del día \(String(describing: updateWorkDay.startDate.toString(format: .custom("dd MMM"))!))?")
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: WorkDay.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let workDay = WorkDay(
        shift: "1",
        startDate: .init(fromString: "2024-02-04T05:27:00+01:00", format: .isoDateTime)!,
        endDate: .init(fromString: "2024-02-04T13:36:00+01:00", format: .isoDateTime)!,
        saturation: 72.1,
        extraTime: 8,
        isAllowance: true
    )
    
    container.mainContext.insert(workDay)
    
    return RecordDetailView(workDay: workDay)
        .modelContainer(for: WorkDay.self, inMemory: true)
}

extension RecordDetailView {
    // MARK: - Extracted views
    var DateHeader: some View {
        VStack {
            Text(updateWorkDay.startDate.formatted(date: .complete, time: .omitted))
                .font(.title.bold())
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)
                .padding(.bottom)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    var ShiftPicker: some View {
        GroupBox {
            LabeledContent("Turno") {
                Menu {
                    ForEach(locations, id: \.self) { location in
                        Picker(location, selection: $shift) {
                            ForEach(shiftsOf(location)) { locationShift in
                                Text(locationShift.name).tag(locationShift as Shift?)
                            }
                        }
                    }
                    .pickerStyle(.menu)
                } label: {
                    Text(shift?.name ?? "")
                        .shiftTextModifier(color: updateWorkDay.color)
                }
                .onChange(of: shift) { shiftChanged() }
            }
        }
        .groupBoxBackGroundStyle()
    }
    
    var ShiftStartAndEnd: some View {
        GroupBox {
            LabeledContent("Inicio de jornada") {
                DatePicker("", selection: $updateWorkDay.startDate, displayedComponents: .hourAndMinute)
            }
            
            LabeledContent("Fin de jornada") {
                DatePicker("", selection: $updateWorkDay.endDate, in: updateWorkDay.startDate..., displayedComponents: .hourAndMinute)
                    .onChange(of: updateWorkDay.endDate) { _, newValue in
                        endDateChanged(newValue: newValue)
                    }
            }
        }
        .groupBoxBackGroundStyle()
    }
    
    var ShiftExtraOptions: some View {
        GroupBox {
            LabeledContent("Duración", value: updateWorkDay.workingHours)
            
            LabeledContent("Saturación", value: updateWorkDay.saturation ?? 0, format: .number)
            
            LabeledContent("Nocturnidad", value: updateWorkDay.nightTimeString)
            
            LabeledContent("Exceso de jornada") {
                Text("\(updateWorkDay.extraTime) min")
            }
            
            LabeledContent("Dieta") {
                Toggle("", isOn: $updateWorkDay.isAllowance)
            }
            
            LabeledContent("Festivo") {
                Toggle("", isOn: $updateWorkDay.isWorkedHoliday)
            }
            
            LabeledContent("Festivo especial") {
                Toggle("", isOn: $updateWorkDay.isSpecialWorkedHoliday)
            }
            
            LabeledContent("Práctica") {
                Toggle("", isOn: $updateWorkDay.isMentoring)
            }
            
            LabeledContent("SPP") {
                Toggle("", isOn: $updateWorkDay.isSPP)
            }
            
            DisclosureGroup("Licencia", isExpanded: $isLicense) {
                Group {
                    LabeledContent("Sin sueldo") {
                        Toggle("", isOn: $updateWorkDay.isFreeLicense)
                    }
                    
                    LabeledContent("Con sueldo") {
                        Toggle("", isOn: $updateWorkDay.isPaidLicense)
                    }
                }
                .padding(.leading)
                .padding(.trailing, 2)
            }
            .foregroundStyle(.white)
            .onAppear(perform: checkIsLicense)
            
            DisclosureGroup("Baja", isExpanded: $isSick) {
                Group {
                    LabeledContent("Por enfermedad") {
                        Toggle("", isOn: $updateWorkDay.isSickLeave)
                    }
                    
                    LabeledContent("Accidente laboral") {
                        Toggle("", isOn: $updateWorkDay.isWorkAccident)
                    }
                }
                .padding(.leading)
                .padding(.trailing, 2)
            }
            .foregroundStyle(.white)
            .onAppear(perform: checkIsSick)
        }
        .groupBoxBackGroundStyle()
        .tint(updateWorkDay.color)
    }

    // MARK: - Computed properties and functions
    var locations: [String] {
        shiftsByLocation.keys.sorted(by: <)
    }
    
    var shifts: [Shift] {
        Array(locations).flatMap { shiftsByLocation[$0] ?? [] }
    }
    
    func shiftsOf(_ location: String) -> [Shift] {
        shiftsByLocation[location]?.sorted() ?? []
    }
    
    func updateRecord() {
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
    
    func deleteRecord() {
        modelContext.delete(workDay)
        dismiss()
    }
    
    func shiftChanged() {
        if let shift,
           let shiftLocation = shiftGroups.shiftLocation(for: shift.id) {
            updateWorkDay.shift = shift.name
            updateWorkDay.startDate = updateWorkDay.startDate.adjust(for: .startOfDay)!.addingTimeInterval(shift.startTime)
            updateWorkDay.endDate = updateWorkDay.startDate.addingTimeInterval(shift.duration)
            updateWorkDay.saturation = shift.saturation
            updateWorkDay.extraTime = 0
            
            if shiftLocation.rawValue != location {
                updateWorkDay.isAllowance = true
            } else {
                updateWorkDay.isAllowance = false
            }
        }
    }
    
    func endDateChanged(newValue: Date) {
        if let shift {
            let selectedShiftEndTime = updateWorkDay.startDate.adjust(for: .startOfDay)!.addingTimeInterval(shift.endTime)
            let extraTime = Int(updateWorkDay.endDate.since(selectedShiftEndTime, in: .minute)!)
            if extraTime > 0 {
                updateWorkDay.extraTime = extraTime
            } else {
                updateWorkDay.extraTime = 0
            }
        }
    }
        
    func checkIsLicense() {
        if updateWorkDay.isFreeLicense || updateWorkDay.isPaidLicense {
            isLicense = true
        }
    }
    
    func checkIsSick() {
        if updateWorkDay.isSickLeave || updateWorkDay.isWorkAccident {
            isSick = true
        }
    }
}
