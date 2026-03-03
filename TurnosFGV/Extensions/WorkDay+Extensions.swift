//
//  WorkDay+Extensions.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 21/3/24.
//

import SwiftData
import SwiftUI

extension WorkDay {
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

    static func monthPredicate(month: Date) -> Predicate<WorkDay> {
        // Get the current month, the previous two and the next two
        let firstDay = month.adding(-2, .month)
        let lastDay = month.adding(2, .month)
        
        return #Predicate<WorkDay> { $0.startDate >= firstDay && $0.startDate < lastDay }
    }
    
    static func monthDescriptor(month: Date) -> FetchDescriptor<WorkDay> {
        let firstDay = month.startOfMonth.startOfWeek.startOfDay
        var lastDay = month.endOfMonth.endOfWeek.endOfDay
        if Calendar.current.dateComponents([.day], from: firstDay, to: lastDay).day! < 42 {
            lastDay = lastDay.adding(1, .weekOfYear)
        }
        
        return FetchDescriptor(predicate: #Predicate<WorkDay> {
            $0.startDate > firstDay && $0.startDate < lastDay
        })
    }
    
    static func allWorkDaysDescriptor() -> FetchDescriptor<WorkDay> {
        FetchDescriptor(sortBy: [SortDescriptor(\.startDate, order: .reverse)])
    }

    static func filtered(_ workDays: [WorkDay], byMonth date: Date) -> [WorkDay] {
        let start = date.startOfMonth.startOfDay
        let end = date.endOfMonth.endOfDay
        return workDays.filter { $0.startDate >= start && $0.startDate <= end }
    }

    static func filtered(_ workDays: [WorkDay], byYear date: Date) -> [WorkDay] {
        let start = date.startOfYear
        let end = date.endOfYear
        return workDays.filter { $0.startDate >= start && $0.startDate <= end }
    }
    
    var viewRecordDuration: String {
        let startTime = startDate.toString("HH:mm")
        let endTime = endDate.toString("HH:mm")
        return "De \(startTime) a \(endTime)"
    }
    
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

    var sppMinutes: Int {
        guard isSPP else { return 0 }
        return Calendar.current.dateComponents([.minute], from: startDate, to: endDate).minute ?? 0
    }
    
    var extraTimeTimeInterval: TimeInterval {
        Double(extraTime * 60)
    }
    
    var workDayNightTime: TimeInterval {
        guard startDate < endDate.addingTimeInterval(extraTimeTimeInterval) else { return 0 }
        return startDate.nightTime(startDate: startDate, endDate: endDate.addingTimeInterval(extraTimeTimeInterval))
    }
    
    var nightTimeString: String {
        workDayNightTime.timeString
    }
    
    var workingHours: String {
        (endDate.addingTimeInterval(extraTimeTimeInterval) - startDate).timeString
    }
    
    var isStandardShift: Bool {
        shift == "STDR"
    }
    
    var typeOfShift: TypeOfShift {
        let startOfDay = Calendar.current.startOfDay(for: startDate)
        let startTime = startDate.timeIntervalSince(startOfDay)
        let endTime = endDate.timeIntervalSince(startOfDay)
        return .determine(startTime: startTime, endTime: endTime)
    }
    
    var color: Color {
        typeOfShift.color
    }

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
