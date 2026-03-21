//
//  PayrollViewModel.swift
//  TurnosFGV
//

import Foundation
import SwiftData

@Observable
final class PayrollViewModel {
    private(set) var workDays: [WorkDay] = []
    var selectedDate: Date = .now

    func load(from context: ModelContext) {
        if let days = try? context.fetch(WorkDay.allWorkDaysDescriptor()) {
            workDays = days
        }
    }

    // MARK: - Helpers

    func recordsByType(_ records: [WorkDay], _ typeOfShift: TypeOfShift) -> (hours: Double, days: Int) {
        let filteredRecords = records.filter { $0.typeOfShift == typeOfShift }
        let hours = filteredRecords.map(\.workedTimeInHours).reduce(0, +)
        return (hours, filteredRecords.count)
    }

    func workedHoursIn(records: [WorkDay]) -> Double {
        records.map(\.workedTimeInHours).reduce(0, +)
    }

    // MARK: - Month computed properties

    var recordsInMonth: [WorkDay] {
        WorkDay.filtered(workDays, byMonth: selectedDate)
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
        notSickRecordsInMonth.compactMap(\.saturation).reduce(0, +)
    }

    var sundaysOrWorkedHolidaysInMonth: Int {
        notSickRecordsInMonth.filter({ $0.isWorkedHoliday || $0.startDate.component(.weekday) == Constants.sundayWeekday }).count
    }

    var saturdaysInMonth: Int {
        notSickRecordsInMonth.filter({ $0.startDate.component(.weekday) == Constants.saturdayWeekday }).count
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

    var recordsInYear: [WorkDay] {
        WorkDay.filtered(workDays, byYear: selectedDate)
    }

    var yearWorkedHours: Double {
        workedHoursIn(records: recordsInYear)
    }

    var workedDaysInCurrentYear: Int {
        recordsInYear.count
    }
}
