//
//  Date+Extensions.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 21/3/24.
//

import Foundation

extension Date {
    /// Returns the difference between two dates as a `TimeInterval` (in seconds).
    static func -(lhs: Date, rhs: Date) -> TimeInterval {
        lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

    /// Standalone weekday symbols starting from Monday (instead of the default Sunday-first order).
    static var weekdaySymbols: [String] {
        Array(Calendar.current.standaloneWeekdaySymbols.dropFirst()) + Calendar.current.standaloneWeekdaySymbols.prefix(1)
    }

    /// Year number extracted from this date.
    var year: Int {
        Calendar.current.component(.year, from: self)
    }

    /// The first day of the current calendar month at midnight.
    static var currentMonth: Date {
        let calendar = Calendar.current

        guard let month = calendar.date(from: calendar.dateComponents([.year, .month], from: .now)) else {
            return .now
        }

        return month
    }

    // MARK: - Initialisers

    /// Creates a `Date` by parsing a string in `yyyy-MM-dd` format using the current time zone.
    ///
    /// - Parameter string: A date string in `yyyy-MM-dd` format (e.g. `"2024-04-09"`).
    init?(isoDate string: String) {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = .current
        guard let d = f.date(from: string) else { return nil }
        self = d
    }

    /// Creates a `Date` by parsing an ISO 8601 string that includes a time-zone offset (e.g. `"+01:00"`).
    ///
    /// - Parameter string: An ISO 8601 date-time string with internet date-time format options.
    init?(isoDateTime string: String) {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        guard let d = f.date(from: string) else { return nil }
        self = d
    }

    // MARK: - Calendar boundaries

    /// The start of the calendar day (midnight) for this date.
    var startOfDay: Date { Calendar.current.startOfDay(for: self) }

    /// The first instant of the calendar month that contains this date.
    var startOfMonth: Date {
        let c = Calendar.current
        return c.date(from: c.dateComponents([.year, .month], from: self))!
    }

    /// The last instant (23:59:59) of the calendar month that contains this date.
    var endOfMonth: Date { Calendar.current.dateInterval(of: .month, for: self)!.end.addingTimeInterval(-1) }

    /// The first instant of the calendar week (Monday) that contains this date.
    var startOfWeek: Date { Calendar.current.dateInterval(of: .weekOfYear, for: self)!.start }

    /// The last instant (Sunday 23:59:59) of the calendar week that contains this date.
    var endOfWeek: Date { Calendar.current.dateInterval(of: .weekOfYear, for: self)!.end.addingTimeInterval(-1) }

    /// The last instant (23:59:59) of the calendar day for this date.
    var endOfDay: Date { Calendar.current.dateInterval(of: .day, for: self)!.end.addingTimeInterval(-1) }

    /// The first instant of the calendar year that contains this date.
    var startOfYear: Date {
        let c = Calendar.current
        return c.date(from: c.dateComponents([.year], from: self))!
    }

    /// The last instant (31 Dec 23:59:59) of the calendar year that contains this date.
    var endOfYear: Date { Calendar.current.dateInterval(of: .year, for: self)!.end.addingTimeInterval(-1) }

    // MARK: - Arithmetic

    /// Returns a new date by adding the given value for the specified calendar component.
    ///
    /// - Parameters:
    ///   - value: The amount to add (may be negative).
    ///   - component: The calendar component to add to (e.g. `.day`, `.month`).
    func adding(_ value: Int, _ component: Calendar.Component) -> Date {
        Calendar.current.date(byAdding: component, value: value, to: self)!
    }

    // MARK: - Time adjustment

    /// Returns a new date equal to this date but with the time set to the given hour and minute.
    ///
    /// - Parameters:
    ///   - hour: The desired hour (0–23).
    ///   - minute: The desired minute (0–59).
    func settingTime(hour: Int, minute: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: self)!
    }

    // MARK: - Comparison

    /// Returns whether this date and `other` fall on the same calendar day.
    ///
    /// - Parameter other: The date to compare against.
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    // MARK: - Component accessor

    /// Extracts the integer value of the given calendar component from this date.
    ///
    /// - Parameter component: The calendar component to extract (e.g. `.year`, `.month`, `.day`).
    /// - Returns: The integer value of the requested component.
    func component(_ component: Calendar.Component) -> Int {
        Calendar.current.component(component, from: self)
    }

    // MARK: - Formatter

    /// Returns a string representation of this date using the given format pattern.
    ///
    /// - Parameter format: A `DateFormatter`-compatible format string (e.g. `"dd/MM/yyyy"`).
    func toString(_ format: String) -> String {
        let f = DateFormatter()
        f.dateFormat = format
        f.locale = .current
        return f.string(from: self)
    }

    // MARK: - Night time boundaries

    /// The 22:00 instant on the same calendar day as this date (start of the nocturnidad period).
    var nightStart: Date {
        self.settingTime(hour: Constants.nightStartHour, minute: 0)
    }

    /// The 06:00 instant on the same calendar day as this date (end of the nocturnidad period).
    var nightEnd: Date {
        self.settingTime(hour: Constants.nightEndHour, minute: 0)
    }

    /// Calculates the number of night-work seconds (nocturnidad) within the given shift range.
    ///
    /// Night hours are those falling between 22:00 and 06:00 of the following day.
    ///
    /// - Parameters:
    ///   - startDate: The shift start date and time.
    ///   - endDate: The shift end date and time.
    /// - Returns: The duration of the night-work period in seconds, or `0` if the range is invalid.
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
