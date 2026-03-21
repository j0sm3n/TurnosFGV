//
//  Constants.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 21/3/24.
//

import Foundation

/// App-wide domain constants for payroll calculations and shift classification.
struct Constants {
    /// Monetary value of a single meal allowance day (dieta), in euros.
    static let allowanceValue: Double = 0.95

    /// User defaults key used to track the current onboarding version shown to the user.
    static let currentOnboardingVersion = "currentOnboardingVersion_1.0.0"

    /// Hour at which the night-work period (nocturnidad) begins (22:00).
    static let nightStartHour: Int = 22
    /// Hour at which the night-work period (nocturnidad) ends (06:00).
    static let nightEndHour: Int = 6

    /// Earliest start time (seconds since midnight) that qualifies as a morning shift.
    static let morningStartHour: TimeInterval = TimeInterval(hour: 4, minute: 0)
    /// Latest start time (seconds since midnight) for a shift to still be classified as morning.
    static let maxMorningStartHour: TimeInterval = TimeInterval(hour: 12, minute: 30)
    /// Latest end time (seconds since midnight) for a shift to still be classified as morning (not noon).
    static let maxMorningEndHour: TimeInterval = TimeInterval(hour: 15, minute: 45)

    /// Weekday index for Sunday in the Gregorian calendar (Sunday = 1).
    static let sundayWeekday: Int = 1
    /// Weekday index for Saturday in the Gregorian calendar (Saturday = 7).
    static let saturdayWeekday: Int = 7

    // MARK: - CloudStorage keys
    static let roleKey = "role"
    static let locationKey = "location"
    static let prevYearHoursKey = "prevYearHours"
}

/// Generic state container for async data loading operations.
enum Loadable<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(String)
}
