//
//  ExtensionTests.swift
//  TurnosFGVTests
//

import Foundation
import Testing
@testable import TurnosFGV

// MARK: - Int.minutesInHours

@Suite("Int.minutesInHours")
struct IntMinutesInHoursTests {

    @Test("Converts exact hours with no remainder",
          arguments: zip([60, 120, 420], [1.0, 2.0, 7.0]))
    func exactHours(minutes: Int, expected: Double) {
        #expect(minutes.minutesInHours == expected)
    }

    @Test("Rounds to 2 decimal places",
          arguments: zip([90, 125, 514], [1.5, 2.08, 8.57]))
    func roundedHours(minutes: Int, expected: Double) {
        #expect(minutes.minutesInHours == expected)
    }

    @Test("Zero minutes returns zero hours")
    func zeroMinutes() {
        #expect(0.minutesInHours == 0.0)
    }
}

// MARK: - Double.roundToDecimal

@Suite("Double.roundToDecimal")
struct DoubleRoundToDecimalTests {

    @Test("Rounds up at midpoint")
    func roundsUp() {
        #expect(8.565.roundToDecimal(2) == 8.57)
        #expect(3.141592.roundToDecimal(3) == 3.142)
    }

    @Test("Rounds down below midpoint")
    func roundsDown() {
        #expect(2.0833.roundToDecimal(2) == 2.08)
        #expect(1.1111.roundToDecimal(3) == 1.111)
    }

    @Test("Returns integer-equivalent value unchanged")
    func wholeNumber() {
        #expect(8.0.roundToDecimal(2) == 8.0)
    }

    @Test("Zero decimal places rounds to nearest integer")
    func zeroDecimalPlaces() {
        #expect(3.7.roundToDecimal(0) == 4.0)
        #expect(3.2.roundToDecimal(0) == 3.0)
    }
}

// MARK: - TimeInterval init and inMinutes

@Suite("TimeInterval(hour:minute:)")
struct TimeIntervalInitTests {

    @Test("Converts hours and minutes to seconds",
          arguments: zip(
            [(hour: 8, minute: 34), (hour: 7, minute: 0), (hour: 0, minute: 40)],
            [30840.0,               25200.0,               2400.0]
          ))
    func conversion(input: (hour: Int, minute: Int), expectedSeconds: Double) {
        #expect(TimeInterval(hour: input.hour, minute: input.minute) == expectedSeconds)
    }

    @Test("Default minute parameter is zero")
    func defaultMinute() {
        #expect(TimeInterval(hour: 7) == TimeInterval(hour: 7, minute: 0))
    }

    @Test("inMinutes converts seconds back to integer minutes",
          arguments: zip(
            [TimeInterval(hour: 8, minute: 34), TimeInterval(hour: 7), TimeInterval(hour: 0, minute: 40)],
            [514, 420, 40]
          ))
    func inMinutes(interval: TimeInterval, expected: Int) {
        #expect(interval.inMinutes == expected)
    }
}
