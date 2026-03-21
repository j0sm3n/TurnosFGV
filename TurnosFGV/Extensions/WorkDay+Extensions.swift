//
//  WorkDay+Extensions.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 21/3/24.
//

import SwiftData
import SwiftUI

extension WorkDay {
    /// Returns a new, non-persisted copy of this record with identical property values.
    func copy() -> WorkDay {
        WorkDay(
            shift: shift,
            startDate: startDate,
            endDate: endDate,
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
    }

    /// Returns a SwiftData predicate that covers records within ±2 months of the given month.
    ///
    /// The wider window ensures that shifts starting near month boundaries are included when
    /// building the visible calendar grid.
    ///
    /// - Parameter month: Any date within the target month.
    static func monthPredicate(month: Date) -> Predicate<WorkDay> {
        // Get the current month, the previous two and the next two
        let firstDay = month.adding(-2, .month)
        let lastDay = month.adding(2, .month)

        return #Predicate<WorkDay> { $0.startDate >= firstDay && $0.startDate < lastDay }
    }

    /// Returns a `FetchDescriptor` that fetches all work-day records sorted by date descending.
    static func allWorkDaysDescriptor() -> FetchDescriptor<WorkDay> {
        FetchDescriptor(sortBy: [SortDescriptor(\.startDate, order: .reverse)])
    }

    /// Filters an array of work days to those whose start date falls within the given month.
    ///
    /// - Parameters:
    ///   - workDays: The source array to filter.
    ///   - date: Any date within the target month.
    static func filtered(_ workDays: [WorkDay], byMonth date: Date) -> [WorkDay] {
        let start = date.startOfMonth.startOfDay
        let end = date.endOfMonth.endOfDay
        return workDays.filter { $0.startDate >= start && $0.startDate <= end }
    }

    /// Filters an array of work days to those whose start date falls within the given year.
    ///
    /// - Parameters:
    ///   - workDays: The source array to filter.
    ///   - date: Any date within the target year.
    static func filtered(_ workDays: [WorkDay], byYear date: Date) -> [WorkDay] {
        let start = date.startOfYear
        let end = date.endOfYear
        return workDays.filter { $0.startDate >= start && $0.startDate <= end }
    }

    /// A formatted string describing the shift time range (e.g. "De 06:20 a 14:39").
    var viewRecordDuration: String {
        let startTime = startDate.toString("HH:mm")
        let endTime = endDate.toString("HH:mm")
        return "De \(startTime) a \(endTime)"
    }

    /// Total worked hours as a decimal value.
    ///
    /// - Returns `0` for SPP shifts.
    /// - Returns the standard STDR duration for sick-leave shifts.
    /// - Otherwise returns the actual elapsed time between start and end dates.
    var workedTimeInHours: Double {
        if isSPP {
            return 0
        } else if isSickLeave {
            let minutes = ShiftsDataModel.shared.standardMinutesFor(date: startDate)
            return minutes.minutesInHours
        } else {
            let minutes = Calendar.current.dateComponents([.minute], from: startDate, to: endDate).minute ?? 0
            return minutes.minutesInHours
        }
    }

    /// Duration of the SPP service in minutes, or `0` when the shift is not an SPP shift.
    var sppMinutes: Int {
        guard isSPP else { return 0 }
        return Calendar.current.dateComponents([.minute], from: startDate, to: endDate).minute ?? 0
    }

    /// Overtime (`extraTime`) converted to seconds.
    var extraTimeTimeInterval: TimeInterval {
        Double(extraTime * 60)
    }

    /// Night-work seconds (nocturnidad) for this shift, including any overtime extension.
    var workDayNightTime: TimeInterval {
        guard startDate < endDate.addingTimeInterval(extraTimeTimeInterval) else { return 0 }
        return startDate.nightTime(startDate: startDate, endDate: endDate.addingTimeInterval(extraTimeTimeInterval))
    }

    /// Night-work duration formatted as a time string (e.g. "01:30").
    var nightTimeString: String {
        workDayNightTime.timeString
    }

    /// Total shift duration (including overtime) formatted as a time string (e.g. "08:09").
    var workingHours: String {
        (endDate.addingTimeInterval(extraTimeTimeInterval) - startDate).timeString
    }

    /// Whether this shift is the standard reference shift (STDR).
    var isStandardShift: Bool {
        shift == "STDR"
    }

    /// The shift type (morning, noon, or afternoon) derived from the start and end times.
    var typeOfShift: TypeOfShift {
        let startOfDay = Calendar.current.startOfDay(for: startDate)
        let startTime = startDate.timeIntervalSince(startOfDay)
        let endTime = endDate.timeIntervalSince(startOfDay)
        return .determine(startTime: startTime, endTime: endTime)
    }

    /// The color associated with this shift's type.
    var color: Color {
        typeOfShift.color
    }

    /// The list of active tags to display on the calendar record cell.
    var activeTags: [WorkDayTag] {
        var tags: [WorkDayTag] = []
        if isAllowance           { tags.append(.allowance) }
        if isWorkedHoliday       { tags.append(.holiday) }
        if isSpecialWorkedHoliday { tags.append(.specialHoliday) }
        if isMentoring           { tags.append(.mentoring) }
        if isSickLeave           { tags.append(.sick) }
        if isWorkAccident        { tags.append(.accident) }
        if isSPP                 { tags.append(.spp) }
        return tags
    }
}
