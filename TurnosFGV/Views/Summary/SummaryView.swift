//
//  SummaryView.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 25/3/24.
//

import SwiftUI
import SwiftData
import CloudStorage

struct SummaryView: View {
    @Environment(\.modelContext) private var modelContext
    @CloudStorage("prevYearHours") var prevYearHours: Double = 0.0
    @Binding var selectedDate: Date
    @Binding var selectedMonth: Date
    @State private var showPayrollGroup: Bool = true
    @State private var workDays: [WorkDay] = []

    var body: some View {
        NavigationStack {
            VStack {
                MonthYearHeader(selectedDate: $selectedDate, selectedMonth: $selectedMonth)
                ScrollView {
                    if recordsInMonth.isEmpty {
                        ContentUnavailableView("No hay registros", systemImage: "doc.text.magnifyingglass")
                            .foregroundStyle(.appWhite)
                            .offset(y: 200)
                    } else {
                        PayrollDisclosureGroup
                        MonthDisclosureGroup
                        YearDisclosureGroup
                    }
                }
                .scrollIndicators(.hidden)
            }
            .background(.appBackground)
            .task {
                if let workDays = try? modelContext.fetch(WorkDay.allWorkDaysDescriptor()) {
                    self.workDays = workDays
                }
            }
        }
    }
}

#Preview {
    SummaryView(selectedDate: .constant(.now), selectedMonth: .constant(.currentMonth))
    #if DEBUG
        .modelContainer(WorkDay.preview)
    #endif
}

extension SummaryView {
    // MARK: - Extracted vies
    var PayrollDisclosureGroup: some View {
        DisclosureGroup(isExpanded: $showPayrollGroup) {
            VStack(spacing: 12) {
                LabeledContent("Nocturnidad", value: nightTimeInMonth, format: .number.precision(.fractionLength(0)))
                LabeledContent("Comp. Jor. Cont. Peculiares", value: noonRecordsCount, format: .number)
                LabeledContent("Prima saturación maquinista", value: saturationInMonth, format: .number.precision(.fractionLength(0)))
                LabeledContent("Indemnización Domingo/Festivo", value: sundaysOrWorkedHolidaysInMonth, format: .number)
                LabeledContent("Indemnización descanso bocadillo", value: snackBreakCompensation, format: .number)
                LabeledContent("Indemnización sábados", value: saturdaysInMonth, format: .number)
                LabeledContent("Horas extras extructurales", value: extraTimeInMonth, format: .number.precision(.fractionLength(2)))
                    .hide(if: extraTimeInMonth == 0)
                LabeledContent("SPP", value: totalSPPHours, format: .number.precision(.fractionLength(2)))
                    .hide(if: totalSPPHours == 0)
                LabeledContent("Dietas", value: numberOfAllowance, format: .number.precision(.fractionLength(2)))
                    .hide(if: numberOfAllowance == 0)
                LabeledContent("Comp. Festivos Especiales", value: numberOfSpecialWorkedHolidays, format: .number)
                    .hide(if: numberOfSpecialWorkedHolidays == 0)
            }
            .padding(.bottom)
        } label: {
            Label("Nómina \(selectedMonth.toString(format: .custom("MMMM yyyy"))!)", systemImage: "doc.text.magnifyingglass")
                .disclosureGroupLabelStyle()
        }
        .disclosureGroupBackgroundStyle()
    }
    
    var MonthDisclosureGroup: some View {
        DisclosureGroup {
            VStack(spacing: 12) {
                LabeledContent("Horas trabajadas", value: monthWorkedHours, format: .number.precision(.fractionLength(2)))
                
                LabeledContent("Dias trabajados", value: workedDaysInCurrentMonth, format: .number)
                
                ForEach(TypeOfShift.allCases, id: \.self) { typeOfShift in
                    let (hours, days) = recordsByType(recordsInMonth, typeOfShift)
                    LabeledContent("\(typeOfShift.rawValue) (\(days))", value: hours, format: .number.precision(.fractionLength(2)))
                }
            }
            .padding(.bottom)
        } label: {
            Label("Datos de \(selectedMonth.toString(format: .custom("MMMM"))!)", systemImage: "\(selectedMonth.component(.month)!).square.fill")
                .disclosureGroupLabelStyle()
        }
        .disclosureGroupBackgroundStyle()
    }
    
    var YearDisclosureGroup: some View {
        DisclosureGroup {
            VStack(spacing: 12) {
                LabeledContent("Horas trabajadas", value: yearWorkedHours, format: .number.precision(.fractionLength(2)))
                
                LabeledContent("Horas año anterior", value: prevYearHours, format: .number.precision(.fractionLength(2)))
                
                LabeledContent("Dias trabajados", value: workedDaysInCurrentYear, format: .number)
                
                ForEach(TypeOfShift.allCases, id: \.self) { typeOfShift in
                    let (hours, days) = recordsByType(recorsInYear, typeOfShift)
                    LabeledContent("\(typeOfShift.rawValue) (\(days))", value: hours, format: .number.precision(.fractionLength(2)))
                }
            }
            .padding(.bottom)
        } label: {
            Label("Datos de \(selectedMonth.toString(format: .isoYear)!)", systemImage: "calendar")
                .disclosureGroupLabelStyle()
        }
        .disclosureGroupBackgroundStyle()
    }

    // MARK: - Computed properties and functions
    func recordsByType(_ records: [WorkDay], _ typeOfShift: TypeOfShift) -> (hours: Double, days: Int) {
        let filteredRecords = records.filter { $0.typeOfShift == typeOfShift }
        let hours = filteredRecords.map(\.workedTimeInHours).reduce(0, +)
        return (hours, filteredRecords.count)
    }
    
    func workedHoursIn(records: [WorkDay]) -> Double {
        records.map(\.workedTimeInHours).reduce(0, +)
    }

    // MARK: - Month computed properties
    
    // All records in selected month
    var recordsInMonth: [WorkDay] {
        let startDateOfMonth = selectedDate.adjust(for: .startOfMonth)!.adjust(for: .startOfDay)!
        let endDateOfMonth = selectedDate.adjust(for: .endOfMonth)!.adjust(for: .endOfDay)!
        let monthRecords = workDays.filter { $0.startDate >= startDateOfMonth && $0.startDate <= endDateOfMonth}
        return monthRecords
    }
    
    var ordinaryRecordsInMonth: [WorkDay] {
        recordsInMonth.filter { !$0.isSPP }
    }
    
    var sppRecordsInMonth: [WorkDay] {
        recordsInMonth.filter { $0.isSPP }
    }
    
    var notSickRecordsInMonth: [WorkDay] {
        ordinaryRecordsInMonth.filter { !$0.isSickLeave && !$0.isWorkAccident }
    }
    
    var monthWorkedHours: Double {
        workedHoursIn(records: ordinaryRecordsInMonth)
    }
    
    var workedDaysInCurrentMonth: Int {
        ordinaryRecordsInMonth.count
    }
    
    var snackBreakCompensation: Int {
        notSickRecordsInMonth.filter({ !$0.isStandardShift }).count
    }
    
    var nightTimeInMonth: Double {
        let totalSeconds = notSickRecordsInMonth.map(\.workDayNightTime).reduce(0, +)
        return totalSeconds / 3600
    }
    
    var noonRecordsCount: Int {
        notSickRecordsInMonth.filter { $0.typeOfShift == .noon }.count
    }
    
    var saturationInMonth: Double {
        notSickRecordsInMonth.reduce(0) { partialResult, record in
            guard let saturation = record.saturation else {
                return partialResult
            }
            return partialResult + saturation
        }
    }
    
    var sundaysOrWorkedHolidaysInMonth: Int {
        notSickRecordsInMonth.filter({ $0.isWorkedHoliday || $0.startDate.component(.weekday) == 1 }).count
    }
    
    var saturdaysInMonth: Int {
        notSickRecordsInMonth.filter({ $0.startDate.component(.weekday) == 7 }).count
    }
    
    var extraTimeInMonth: Double {
        notSickRecordsInMonth.map(\.extraTime).reduce(0, +).minutesInHours
    }
    
    var totalSPPHours: Double {
        sppRecordsInMonth.map(\.sppMinutes).reduce(0, +).minutesInHours
    }
    
    var numberOfAllowance: Double {
        let allowanceDays = notSickRecordsInMonth.filter { $0.isAllowance }.count
        return Double(allowanceDays) * Constants.allowanceValue
    }
    
    var numberOfSpecialWorkedHolidays: Int {
        notSickRecordsInMonth.filter { $0.isSpecialWorkedHoliday }.count
    }

    // MARK: - Year computed properties
    var recorsInYear: [WorkDay] {
        let firstDayOfYear = selectedDate.adjust(for: .startOfYear)!
        let lastDayOfYear = selectedDate.adjust(for: .endOfYear)!
        return workDays.filter { $0.startDate >= firstDayOfYear && $0.startDate <= lastDayOfYear }
    }
    
    var yearWorkedHours: Double {
        workedHoursIn(records: recorsInYear)
    }
    
    var workedDaysInCurrentYear: Int {
        recorsInYear.count
    }
}
