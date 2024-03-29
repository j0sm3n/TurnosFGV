//
//  Shift+Extensions.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 22/3/24.
//

import SwiftUI

extension Shift {
    var endTime: TimeInterval {
        startTime + duration
    }
    
    private var startDate: Date {
        Date.now.adjust(for: .startOfDay)!.addingTimeInterval(startTime)
    }
    
    private var endDate: Date {
        startDate.addingTimeInterval(duration)
    }
    
    var viewStartString: String {
        startDate.formatted(date: .omitted, time: .shortened)
    }
    
    var viewEndString: String {
        startDate.addingTimeInterval(duration).formatted(date: .omitted, time: .shortened)
    }
    
    var shiftNightTime: TimeInterval {
        Date().nightTime(startDate: startDate, endDate: endDate)
    }
    
    var nightTimeString: String {
        shiftNightTime.timeString
    }
    
    var workingHours: String {
        duration.timeString
    }
    
    var typeOfShift: TypeOfShift {
        let maxMorningStart = TimeInterval(hour: 12, minute: 30)
        let maxMorningEnd = TimeInterval(hour: 15, minute: 45)
        
        var shiftIsMorning: Bool {
            startTime < maxMorningStart && endTime < maxMorningEnd
        }
        
        var shiftIsNoon: Bool {
            startTime < maxMorningStart && endTime > maxMorningEnd
        }
        
        if shiftIsMorning {
            return .morning
        } else if shiftIsNoon {
            return .noon
        } else {
            return .afternoon
        }
    }
    
    var color: Color {
        typeOfShift.color
    }
}

extension Shift: Equatable, Comparable, Hashable {
    static func == (lhs: Shift, rhs: Shift) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func < (lhs: Shift, rhs: Shift) -> Bool {
        lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
    }
}
