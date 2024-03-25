//
//  RecordDetailView.swift
//  RegistroTurnos2
//
//  Created by Jose Antonio Mendoza on 16/2/24.
//

import SwiftData
import SwiftUI
import DateHelper

struct RecordDetailView: View {
    // Environment properties
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // AppStorage properties
    @AppStorage("location") var location: String = ""
    
    // View properties
    @State private var isLicense: Bool = false
    @State private var isSick: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var shiftsByLocation: [String: [Shift]] = [:]
    
    // Record to edit
    @Bindable var workDay: WorkDay
    
    // Shifts Data Model
    let shiftGroups = ShiftsDataModel()
    
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
            
            SaveButton(text: "Actualizar", color: workDay.color, action: updateRecord)
        }
        .padding()
        .background(.appBackground)
        .task {
            shiftsByLocation = shiftGroups.getActualShiftsByLocation(workDay.startDate)
        }
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button("Borrar", role: .destructive) {
                    showDeleteAlert = true
                }
                .tint(.red)
            }
        }
        .alert("Borrar turno \(workDay.shift)", isPresented: $showDeleteAlert) {
            Button("Borrar", role: .destructive, action: deleteRecord)
            Button("Cancelar", role: .cancel, action: {})
        } message: {
            Text("¿Seguro que quieres borrar el turno del día \(String(describing: workDay.startDate.toString(format: .custom("dd MMM"))!))?")
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
}

// MARK: - Extracted views
extension RecordDetailView {
    private var DateHeader: some View {
        VStack {
            Text(workDay.startDate.formatted(date: .complete, time: .omitted))
                .font(.title.bold())
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)
                .padding(.bottom)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private var ShiftPicker: some View {
        GroupBox {
            LabeledContent("Turno") {
                Menu {
                    ForEach(locations, id: \.self) { location in
                        Picker(location, selection: $workDay.shift) {
                            ForEach(shiftsOf(location)) { shift in
                                Text(shift.name).tag(shift.name)
                            }
                        }
                    }
                    .pickerStyle(.menu)
                } label: {
                    Text(workDay.shift)
                        .shiftTextModifier(color: workDay.color)
                }
                .onChange(of: workDay.shift) {
                    workDay.extraTime = 0
                }
            }
        }
        .groupBoxBackGroundStyle()
    }
    
    private var ShiftStartAndEnd: some View {
        GroupBox {
            LabeledContent("Inicio de jornada") {
                DatePicker("", selection: $workDay.startDate, displayedComponents: .hourAndMinute)
            }
            
            LabeledContent("Fin de jornada") {
                DatePicker("", selection: $workDay.endDate, displayedComponents: .hourAndMinute)
                    .onChange(of: workDay.endDate) { oldValue, newValue in
                        if newValue < workDay.startDate {
                            workDay.endDate = workDay.endDate.offset(.day, value: 1)!
                        }
                        if let selectedShift {
                            let selectedShiftEndTime = workDay.startDate.adjust(for: .startOfDay)!.addingTimeInterval(selectedShift.endTime)
                            let extraTime = Int(workDay.endDate.since(selectedShiftEndTime, in: .minute)!)
                            if extraTime > 0 {
                                workDay.extraTime = extraTime
                            } else {
                                workDay.extraTime = 0
                            }
                        }
                    }
            }
        }
        .groupBoxBackGroundStyle()
    }
    
    private var ShiftExtraOptions: some View {
        GroupBox {
            LabeledContent("Duración", value: workDay.workingHours)
            
            LabeledContent("Saturación", value: workDay.saturation ?? 0, format: .number)
            
            LabeledContent("Nocturnidad", value: workDay.nightTimeString)
            
            LabeledContent("Exceso de jornada") {
                Text("\(workDay.extraTime) min")
            }
            
            LabeledContent("Dieta") {
                Toggle("", isOn: $workDay.isAllowance)
            }
            
            LabeledContent("Festivo") {
                Toggle("", isOn: $workDay.isWorkedHoliday)
            }
            
            LabeledContent("Festivo especial") {
                Toggle("", isOn: $workDay.isSpecialWorkedHoliday)
            }
            
            LabeledContent("Práctica") {
                Toggle("", isOn: $workDay.isMentoring)
            }
            
            LabeledContent("SPP") {
                Toggle("", isOn: $workDay.isSPP)
            }
            
            DisclosureGroup("Licencia", isExpanded: $isLicense) {
                Group {
                    LabeledContent("Sin sueldo") {
                        Toggle("", isOn: $workDay.isFreeLicense)
                    }
                    
                    LabeledContent("Con sueldo") {
                        Toggle("", isOn: $workDay.isPaidLicense)
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
                        Toggle("", isOn: $workDay.isSickLeave)
                    }
                    
                    LabeledContent("Accidente laboral") {
                        Toggle("", isOn: $workDay.isWorkAccident)
                    }
                }
                .padding(.leading)
                .padding(.trailing, 2)
            }
            .foregroundStyle(.white)
            .onAppear(perform: checkIsSick)
        }
        .groupBoxBackGroundStyle()
        .tint(workDay.color)
        .onChange(of: workDay.shift) { _, newShiftString in
            updateRecordWith(newShift: newShiftString)
        }
    }
}

// MARK: - Computed properties and functions
extension RecordDetailView {
    var locations: [String] {
        shiftsByLocation.keys.sorted(by: <)
    }
    
    var shifts: [Shift] {
        Array(locations).flatMap { shiftsByLocation[$0] ?? [] }
    }
    
    func shiftsOf(_ location: String) -> [Shift] {
        shiftsByLocation[location]?.sorted() ?? []
    }
    
    var selectedShift: Shift? {
        shifts.first(where: { $0.name == workDay.shift })
    }
    
    func updateRecord() {
        dismiss()
    }
    
    func deleteRecord() {
        modelContext.delete(workDay)
        dismiss()
    }
    
    func updateRecordWith(newShift: String) {
        if let newShift = shifts.first(where: { $0.name == newShift }) {
            workDay.startDate = workDay.startDate.adjust(for: .startOfDay)!.addingTimeInterval(newShift.startTime)
            workDay.endDate = workDay.startDate.addingTimeInterval(newShift.duration)
            workDay.saturation = newShift.saturation
            
            if let shiftGroup = shiftGroups.shiftGroup(for: newShift.id) {
                if self.location != shiftGroup.location.rawValue {
                    workDay.isAllowance = true
                } else {
                    workDay.isAllowance = false
                }
            }
        }
    }
    
    func checkIsLicense() {
        if workDay.isFreeLicense || workDay.isPaidLicense {
            isLicense = true
        }
    }
    
    func checkIsSick() {
        if workDay.isSickLeave || workDay.isWorkAccident {
            isSick = true
        }
    }
}
