//
//  WorkDay+Extensions.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 21/3/24.
//

import SwiftUI
import DateHelper

extension WorkDay {
    static func monthPredicate(month: Date) -> Predicate<WorkDay> {
        // Get the current month, the previous two and the next two
        let firstDay = month.offset(.month, value: -2)!
        let lastDay = month.offset(.month, value: 2)!
        
        return #Predicate<WorkDay> { $0.startDate >= firstDay && $0.startDate < lastDay }
    }
    
    var viewRecordDuration: String {
        let startTime = String(describing: startDate.toString(format: .custom("HH:mm"))!)
        let endTime = String(describing: endDate.toString(format: .custom("HH:mm"))!)
        return "De \(startTime) a \(endTime)"
    }
    
    var workedTimeInHours: Double {
        if isSPP {
            return 0
        } else if isSickLeave {
            let minutes = Constants.standardWorkDayMinutes
            return minutes.minutesInHours
        } else {
            // Extratime does not count for the total time worked, it only appears in the monthly payroll
            let minutes = Calendar.current.dateComponents([.minute], from: startDate, to: endDate).minute! // + extraTime
            return minutes.minutesInHours
        }
    }
    
    var sppMinutes: Int {
        guard isSPP else { return 0 }
        return Calendar.current.dateComponents([.minute], from: startDate, to: endDate).minute!
    }
    
    var extraTimeTimeInterval: TimeInterval {
        Double(extraTime * 60)
    }
    
    var workDayNightTime: TimeInterval {
        guard startDate < endDate.addingTimeInterval(extraTimeTimeInterval) else { return 0 }
        return Date().nightTime(startDate: startDate, endDate: endDate.addingTimeInterval(extraTimeTimeInterval))
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
        if startDate > startDate.morningStart && startDate < startDate.maxMorningStart && endDate < startDate.maxMorningEnd { return .morning }
        else if startDate < startDate.maxMorningStart && endDate > startDate.maxMorningEnd { return .noon }
        else { return .afternoon }
    }
    
    var color: Color {
        typeOfShift.color
    }
}
