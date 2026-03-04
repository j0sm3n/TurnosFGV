//
//  DateExtensionsTests.swift
//  TurnosFGVTests
//

import Foundation
import Testing
@testable import TurnosFGV

@Suite("Date extensions")
struct DateExtensionsTests {

    let march4  = Date(isoDate: "2026-03-04")!
    let march1  = Date(isoDate: "2026-03-01")!
    let march31 = Date(isoDate: "2026-03-31")!

    // MARK: - Calendar boundaries

    @Test("startOfMonth returns first day at midnight")
    func startOfMonth() {
        #expect(march4.startOfMonth == march1.startOfDay)
    }

    @Test("endOfMonth falls within the last day of the month")
    func endOfMonth() {
        let end = march4.endOfMonth
        #expect(end.component(.month) == 3)
        #expect(end.component(.day) == 31)
    }

    @Test("startOfYear returns January 1 of the same year")
    func startOfYear() {
        let jan1 = Date(isoDate: "2026-01-01")!
        #expect(march4.startOfYear == jan1.startOfDay)
    }

    @Test("endOfYear falls on December 31")
    func endOfYear() {
        let end = march4.endOfYear
        #expect(end.component(.year) == 2026)
        #expect(end.component(.month) == 12)
        #expect(end.component(.day) == 31)
    }

    // MARK: - isSameDay

    @Test("isSameDay returns true for two times on the same calendar day")
    func sameDayReturnsTrue() {
        let morning = march4.settingTime(hour: 6, minute: 0)
        let evening = march4.settingTime(hour: 22, minute: 30)
        #expect(morning.isSameDay(as: evening))
    }

    @Test("isSameDay returns false for different calendar days")
    func differentDayReturnsFalse() {
        let march5 = Date(isoDate: "2026-03-05")!
        #expect(!march4.isSameDay(as: march5))
    }

    // MARK: - nightTime

    @Test("nightTime for early morning shift (05:00–13:00) = 3600 seconds")
    func earlyMorningNightTime() {
        let start = march4.settingTime(hour: 5, minute: 0)
        let end   = march4.settingTime(hour: 13, minute: 0)
        // Overlaps 05:00–06:00 = 1 hour = 3600 s
        #expect(start.nightTime(startDate: start, endDate: end) == 3600)
    }

    @Test("nightTime for evening shift (14:00–23:00) = 3600 seconds")
    func eveningNightTime() {
        let start = march4.settingTime(hour: 14, minute: 0)
        let end   = march4.settingTime(hour: 23, minute: 0)
        // Overlaps 22:00–23:00 = 1 hour = 3600 s
        #expect(start.nightTime(startDate: start, endDate: end) == 3600)
    }

    @Test("nightTime for daytime shift (07:00–15:00) = 0")
    func daytimeNightTime() {
        let start = march4.settingTime(hour: 7, minute: 0)
        let end   = march4.settingTime(hour: 15, minute: 0)
        #expect(start.nightTime(startDate: start, endDate: end) == 0)
    }

    @Test("nightTime for partial morning overlap (05:20–13:54) = 40 minutes")
    func partialMorningNightTime() {
        let start = march4.settingTime(hour: 5, minute: 20)
        let end   = march4.settingTime(hour: 13, minute: 54)
        // 05:20–06:00 = 40 min = 2400 s
        #expect(start.nightTime(startDate: start, endDate: end) == 2400)
    }

    @Test("nightTime when startDate equals endDate returns 0")
    func zeroLengthShift() {
        let start = march4.settingTime(hour: 8, minute: 0)
        #expect(start.nightTime(startDate: start, endDate: start) == 0)
    }

    // MARK: - component accessor

    @Test("component accessor extracts year, month, and day correctly")
    func componentAccessor() {
        #expect(march4.component(.year) == 2026)
        #expect(march4.component(.month) == 3)
        #expect(march4.component(.day) == 4)
    }
}
