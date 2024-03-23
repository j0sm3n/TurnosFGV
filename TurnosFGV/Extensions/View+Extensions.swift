//
//  View+Extensions.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 22/3/24.
//

import SwiftUI
import DateHelper

extension View {
    @ViewBuilder
    func hSpacing(_ alignment: Alignment) -> some View {
        self.frame(maxWidth: .infinity, alignment: alignment)
    }
    
    @ViewBuilder
    func vSpacing(_ alignment: Alignment) -> some View {
        self.frame(maxHeight: .infinity, alignment: alignment)
    }

    /// Extracting Dates for the Given Month
    func extractDates(_ month: Date) -> [Day] {
        var days: [Day] = []
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        
        guard let range = calendar.range(of: .day, in: .month, for: month)?.compactMap({ value -> Date? in
            return calendar.date(byAdding: .day, value: value - 1, to: month)
        }) else {
            return days
        }
        
        var firstWeekDay = calendar.component(.weekday, from: range.first!) - 1
        if firstWeekDay == 0 {
            firstWeekDay = 7
        }

        for index in Array(0..<firstWeekDay - 1).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -index - 1, to: range.first!) else { return days }
            let shortSymbol = formatter.string(from: date)
            days.append(.init(shortSymbol: shortSymbol, date: date, ignored: true))
        }
        
        range.forEach { date in
            let shortSymbol = formatter.string(from: date)
            days.append(.init(shortSymbol: shortSymbol, date: date.adjust(hour: 12, minute: 0)!))
        }
        
        var lastWeekDay = 7 - calendar.component(.weekday, from: range.last!) + 1
        if lastWeekDay == 7 {
            lastWeekDay = 0
        }

        if lastWeekDay > 0 {
            for index in 0..<lastWeekDay {
                guard let date = calendar.date(byAdding: .day, value: index + 1, to: range.last!) else { return days }
                let shortSymbol = formatter.string(from: date)
                days.append(.init(shortSymbol: shortSymbol, date: date, ignored: true))
            }
        }
        
        if days.count < 42, let lastDay = days.last?.date {
            for index in 0..<7 {
                guard let date = calendar.date(byAdding: .day, value: index + 1, to: lastDay) else { return days }
                let shortSymbol = formatter.string(from: date)
                days.append(.init(shortSymbol: shortSymbol, date: date, ignored: true))
            }
        }
        
        return days
    }
}
