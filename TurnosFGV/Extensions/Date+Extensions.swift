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
}
