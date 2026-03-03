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
        Array(Calendar.current.standaloneWeekdaySymbols.dropFirst()) + Calendar.current.standaloneWeekdaySymbols.prefix(1)
    }

    /// Year number from date
    var year: Int {
        Calendar.current.component(.year, from: self)
    }

    /// Current month
    static var currentMonth: Date {
        let calendar = Calendar.current

        guard let month = calendar.date(from: calendar.dateComponents([.year, .month], from: .now)) else {
            return .now
        }

        return month
    }

    // MARK: - Initialisers

    init?(isoDate string: String) {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = .current
        guard let d = f.date(from: string) else { return nil }
        self = d
    }

    init?(isoDateTime string: String) {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        guard let d = f.date(from: string) else { return nil }
        self = d
    }

    // MARK: - Calendar boundaries

    var startOfDay: Date { Calendar.current.startOfDay(for: self) }

    var startOfMonth: Date {
        let c = Calendar.current
        return c.date(from: c.dateComponents([.year, .month], from: self))!
    }

    var endOfMonth: Date { Calendar.current.dateInterval(of: .month, for: self)!.end.addingTimeInterval(-1) }

    var startOfWeek: Date { Calendar.current.dateInterval(of: .weekOfYear, for: self)!.start }

    var endOfWeek: Date { Calendar.current.dateInterval(of: .weekOfYear, for: self)!.end.addingTimeInterval(-1) }

    var endOfDay: Date { Calendar.current.dateInterval(of: .day, for: self)!.end.addingTimeInterval(-1) }

    var startOfYear: Date {
        let c = Calendar.current
        return c.date(from: c.dateComponents([.year], from: self))!
    }

    var endOfYear: Date { Calendar.current.dateInterval(of: .year, for: self)!.end.addingTimeInterval(-1) }

    // MARK: - Arithmetic

    func adding(_ value: Int, _ component: Calendar.Component) -> Date {
        Calendar.current.date(byAdding: component, value: value, to: self)!
    }

    // MARK: - Time adjustment

    func settingTime(hour: Int, minute: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: self)!
    }

    // MARK: - Comparison

    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    // MARK: - Component accessor

    func component(_ component: Calendar.Component) -> Int {
        Calendar.current.component(component, from: self)
    }

    // MARK: - Formatter

    func toString(_ format: String) -> String {
        let f = DateFormatter()
        f.dateFormat = format
        f.locale = .current
        return f.string(from: self)
    }

    // MARK: - Night time boundaries

    var nightStart: Date {
        self.settingTime(hour: Constants.nightStartHour, minute: 0)
    }

    var nightEnd: Date {
        self.settingTime(hour: Constants.nightEndHour, minute: 0)
    }

    func nightTime(startDate: Date, endDate: Date) -> TimeInterval {
        var nightTime: TimeInterval = 0

        guard startDate < endDate else { return 0 }

        // Work day start and end are in the same day
        if startDate.isSameDay(as: endDate) {
            // Work day start before 6:00
            if startDate < endDate.nightEnd && startDate.isSameDay(as: endDate.nightEnd) {
                nightTime = endDate.nightEnd - startDate
            }
            // Work day end after 22:00
            else if endDate > startDate.nightStart {
                nightTime = endDate - startDate.nightStart
            }
        }
        // Work day ends next day
        else {
            // Work day start after 22:00
            if startDate > startDate.nightStart {
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
