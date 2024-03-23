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
        let startTime = String(describing: startDate.toString(format: .custom("HH:mm")))
        let endTime = String(describing: endDate.toString(format: .custom("HH:mm")))
        return "De \(startTime) a \(endTime)"
    }
    
    var workedMinutes: Int {
        if isSPP {
            return 0
        } else if isSickLeave {
            return Constants.standardWorkDayMinutes
        } else {
            // Extratime does not count for the total time worked, it only appears in the monthly payroll
            return Calendar.current.dateComponents([.minute], from: startDate, to: endDate).minute! // + extraTime
        }
    }
    
    var sppMinutes: Int {
        guard isSPP else { return 0 }
        return Calendar.current.dateComponents([.minute], from: startDate, to: endDate).minute!
    }
    
    var morningStart: Date {
        startDate.adjust(hour: 4, minute: 0, second: 0)!
    }
    
    var maxMorningStart: Date {
        startDate.adjust(hour: 12, minute: 30, second: 0)!
    }
    
    var maxMorningEnd: Date {
        startDate.adjust(hour: 15, minute: 45, second: 0)!
    }
    
    var nightStart: Date {
        startDate.adjust(hour: 22, minute: 0, second: 0)!
    }
    
    var nightEnd: Date {
        endDate.adjust(hour: 6, minute: 0, second: 0)!
    }
    
    var nightTime: TimeInterval {
        var nightTime: TimeInterval = 0
        
        if startDate.compare(.isEarlier(than: endDate)) {
            // Night shift, shift ends next day
            if startDate.compare(.isLater(than: nightStart)) && endDate.compare(.isEarlier(than: nightEnd)) {
                nightTime = endDate - startDate
            } else if startDate.compare(.isEarlier(than: nightStart)) && endDate.compare(.isEarlier(than: nightEnd)) {
                nightTime = endDate - nightStart
            } else if startDate.compare(.isLater(than: nightStart)) && endDate.compare(.isLater(than: nightEnd)) {
                nightTime = nightEnd - startDate
            } else {
                nightTime = nightEnd - nightStart
            }
        } else if startDate.compare(.isEarlier(than: nightEnd)) {
            // Morning shift
            nightTime = nightEnd - startDate
        } else if endDate.compare(.isLater(than: nightStart)) {
            // Afternoon shift
            nightTime = endDate - nightStart
        }
        
        return nightTime
    }
    
    var nightTimeString: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: nightTime) ?? ""
    }
    
    var workingHours: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .abbreviated
        let workingHours = endDate - startDate
        return formatter.string(from: workingHours) ?? ""
    }
    
    var isStandardShift: Bool {
        shift == "STDR"
    }
    
    var typeOfShift: TypeOfShift {
        if startDate > morningStart && startDate < maxMorningStart && endDate < maxMorningEnd { return .morning }
        else if startDate < maxMorningStart && endDate > maxMorningEnd { return .noon }
        else { return .afternoon }
    }
    
    var color: Color {
        typeOfShift.color
    }
}
