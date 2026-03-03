//
//  Constants.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 21/3/24.
//

import Foundation

struct Constants {
    // Value of every allowance day
    static let allowanceValue: Double = 0.95

    // Onboarding version
    static let currentOnboardingVersion = "currentOnboardingVersion_1.0.0"

    // Night time boundaries (nocturnidad)
    static let nightStartHour: Int = 22
    static let nightEndHour: Int = 6

    // Shift type determination boundaries
    static let morningStartHour: TimeInterval = TimeInterval(hour: 4, minute: 0)
    static let maxMorningStartHour: TimeInterval = TimeInterval(hour: 12, minute: 30)
    static let maxMorningEndHour: TimeInterval = TimeInterval(hour: 15, minute: 45)

    // Calendar weekday indices (Sunday = 1, Saturday = 7 in Gregorian calendar)
    static let sundayWeekday: Int = 1
    static let saturdayWeekday: Int = 7
}
