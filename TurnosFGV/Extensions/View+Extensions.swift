//
//  View+Extensions.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 22/3/24.
//

import SwiftUI

extension View {
    /// Expands the view to fill all available horizontal space with the given alignment.
    ///
    /// - Parameter alignment: The alignment to apply to the view within the expanded frame.
    @ViewBuilder
    func hSpacing(_ alignment: Alignment) -> some View {
        self.frame(maxWidth: .infinity, alignment: alignment)
    }

    /// Expands the view to fill all available vertical space with the given alignment.
    ///
    /// - Parameter alignment: The alignment to apply to the view within the expanded frame.
    @ViewBuilder
    func vSpacing(_ alignment: Alignment) -> some View {
        self.frame(maxHeight: .infinity, alignment: alignment)
    }
}

extension Calendar {
    /// Generates the array of ``Day`` values that populate the calendar month grid for the given month.
    ///
    /// The result always contains at least 42 entries (6 × 7 grid) so that all rows are filled.
    /// Days from the preceding and following months are included with `ignored == true` as padding
    /// for the partial first and last weeks.
    ///
    /// - Parameter month: The first day of the target month.
    /// - Returns: An ordered array of ``Day`` values ready to be rendered in the calendar grid.
    func extractDates(_ month: Date) -> [Day] {
        var days: [Day] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"

        guard let range = self.range(of: .day, in: .month, for: month)?.compactMap({ value -> Date? in
            return self.date(byAdding: .day, value: value - 1, to: month)
        }), let firstDay = range.first, let lastDay = range.last else {
            return days
        }

        var firstWeekDay = self.component(.weekday, from: firstDay) - 1
        if firstWeekDay == 0 {
            firstWeekDay = 7
        }

        for index in Array(0..<firstWeekDay - 1).reversed() {
            guard let date = self.date(byAdding: .day, value: -index - 1, to: firstDay) else { return days }
            let shortSymbol = formatter.string(from: date)
            days.append(.init(shortSymbol: shortSymbol, date: date, ignored: true))
        }

        range.forEach { date in
            let shortSymbol = formatter.string(from: date)
            days.append(.init(shortSymbol: shortSymbol, date: date.settingTime(hour: 12, minute: 0)))
        }

        var lastWeekDay = 7 - self.component(.weekday, from: lastDay) + 1
        if lastWeekDay == 7 {
            lastWeekDay = 0
        }

        if lastWeekDay > 0 {
            for index in 0..<lastWeekDay {
                guard let date = self.date(byAdding: .day, value: index + 1, to: lastDay) else { return days }
                let shortSymbol = formatter.string(from: date)
                days.append(.init(shortSymbol: shortSymbol, date: date, ignored: true))
            }
        }

        if days.count < 42, let paddingStart = days.last?.date {
            for index in 0..<7 {
                guard let date = self.date(byAdding: .day, value: index + 1, to: paddingStart) else { return days }
                let shortSymbol = formatter.string(from: date)
                days.append(.init(shortSymbol: shortSymbol, date: date, ignored: true))
            }
        }

        return days
    }
}
