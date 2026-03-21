//
//  TypeOfShiftTests.swift
//  TurnosFGVTests
//

import Foundation
import Testing
@testable import TurnosFGV

@Suite("TypeOfShift.determine")
struct TypeOfShiftTests {

    // MARK: - Morning: 04:00 < start < 12:30 AND end < 15:45

    @Test(
        "Classifies morning shifts correctly",
        arguments: zip(
            [
                TimeInterval(hour: 5, minute: 20),  // Turno 1 Benidorm
                TimeInterval(hour: 6, minute: 20),  // Turno 2 Benidorm
                TimeInterval(hour: 9, minute: 20),  // Turno 4 Benidorm (ver. 2025)
                TimeInterval(hour: 4, minute: 1),   // just past morningStartHour boundary
            ],
            [
                TimeInterval(hour: 13, minute: 54),
                TimeInterval(hour: 14, minute: 54),
                TimeInterval(hour: 15, minute: 44), // just before maxMorningEndHour (15:45)
                TimeInterval(hour: 15, minute: 44),
            ]
        )
    )
    func morningShifts(start: TimeInterval, end: TimeInterval) {
        #expect(TypeOfShift.determine(startTime: start, endTime: end) == .morning)
    }

    // MARK: - Noon: start < 12:30 AND end > 15:45

    @Test(
        "Classifies noon shifts correctly",
        arguments: zip(
            [
                TimeInterval(hour: 9, minute: 35),  // Turno 23 Denia (2023)
                TimeInterval(hour: 11, minute: 52), // Turno 3 Benidorm (2023)
                TimeInterval(hour: 8, minute: 35),  // Turno 23 Denia (2024)
            ],
            [
                TimeInterval(hour: 16, minute: 57),
                TimeInterval(hour: 19, minute: 36),
                TimeInterval(hour: 16),             // 16:00 > 15:45
            ]
        )
    )
    func noonShifts(start: TimeInterval, end: TimeInterval) {
        #expect(TypeOfShift.determine(startTime: start, endTime: end) == .noon)
    }

    // MARK: - Afternoon: start ≥ 12:30 OR start before 04:00 (night/early)

    @Test(
        "Classifies afternoon shifts correctly",
        arguments: zip(
            [
                TimeInterval(hour: 13, minute: 45), // Turno 3 Benidorm (2024)
                TimeInterval(hour: 14, minute: 20), // Turno 5 Benidorm (2025)
                TimeInterval(hour: 23, minute: 45), // Turno A11 Benidorm (night)
                TimeInterval(hour: 0, minute: 40),  // Turno A25 Benidorm (pre-dawn, before 04:00)
            ],
            [
                TimeInterval(hour: 22, minute: 53),
                TimeInterval(hour: 22, minute: 39),
                TimeInterval(hour: 29, minute: 55), // 23:45 + 6:10 → next-day endpoint
                TimeInterval(hour: 5, minute: 57),
            ]
        )
    )
    func afternoonShifts(start: TimeInterval, end: TimeInterval) {
        #expect(TypeOfShift.determine(startTime: start, endTime: end) == .afternoon)
    }

    // MARK: - Boundary cases

    @Test("Exactly at morningStartHour boundary (04:00) is not morning")
    func atMorningStartBoundary() {
        // start == morningStartHour is NOT > morningStartHour, so not morning
        let start = TimeInterval(hour: 4, minute: 0)
        let end = TimeInterval(hour: 12, minute: 0)
        #expect(TypeOfShift.determine(startTime: start, endTime: end) != .morning)
    }

    @Test("TypeOfShift raw values match expected Spanish labels")
    func rawValues() {
        #expect(TypeOfShift.morning.rawValue == "Mañana")
        #expect(TypeOfShift.noon.rawValue == "Intermedio")
        #expect(TypeOfShift.afternoon.rawValue == "Tarde")
    }
}
