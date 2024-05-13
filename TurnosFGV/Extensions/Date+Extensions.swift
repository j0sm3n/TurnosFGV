//
//  Date+Extensions.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 21/3/24.
//

import Foundation

extension Date {
    static func -(lhs: Date, rhs: Date) -> TimeInterval {
        lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
    
    /// Week days starting by monday
    static var weekdaySymbols: [String] {
        Calendar.current.standaloneWeekdaySymbols.dropFirst() + [Calendar.current.standaloneWeekdaySymbols.first!]
    }
    
    /// Current month
    static var currentMonth: Date {
        let calendar = Calendar.current
        
        guard let month = calendar.date(from: calendar.dateComponents([.year, .month], from: .now)) else {
            return .now
        }
        
        return month
    }
    
    var year: Int {
        Calendar.current.component(.year, from: self)
    }
    
    var morningStart: Date {
        self.adjust(hour: 4, minute: 0, second: 0)!
    }
    
    var maxMorningStart: Date {
        self.adjust(hour: 12, minute: 30, second: 0)!
    }
    
    var maxMorningEnd: Date {
        self.adjust(hour: 15, minute: 45, second: 0)!
    }
    
    var nightStart: Date {
        self.adjust(hour: 22, minute: 0, second: 0)!
    }
    
    var nightEnd: Date {
        self.adjust(hour: 6, minute: 0, second: 0)!
    }
    
    func nightTime(startDate: Date, endDate: Date) -> TimeInterval {
        var nightTime: TimeInterval = 0
        
        assert(startDate.compare(.isEarlier(than: endDate)), "Start date always has to be earlier than end date")
        
        // Work day start and end are in the same day
        if startDate.compare(.isSameDay(as: endDate)) {
            // Work day start before 6:00
            if startDate.compare(.isEarlier(than: endDate.nightEnd)) && startDate.compare(.isSameDay(as: endDate.nightEnd)) {
                nightTime = endDate.nightEnd - startDate
            }
            // Work day end after 22:00
            else if endDate.compare(.isLater(than: startDate.nightStart)) {
                nightTime = endDate - startDate.nightStart
            }
        }
        // Work day ends next day
        else {
            // Work day start after 22:00
            if startDate.compare(.isLater(than: startDate.nightStart)) {
                nightTime = endDate - startDate
            }
            // Work day start before 22:00
            else {
                nightTime = endDate - startDate.nightStart
            }
        }
        
        return nightTime
    }
}
