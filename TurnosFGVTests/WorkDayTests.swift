//
//  WorkDayTests.swift
//  TurnosFGVTests
//

import Foundation
import Testing
@testable import TurnosFGV

@Suite("WorkDay computed properties")
struct WorkDayTests {

    // Reference date: Tuesday 4 March 2026
    let date = Date(isoDate: "2026-03-04")!

    // MARK: - workedTimeInHours

    @Suite("workedTimeInHours")
    struct WorkedTimeTests {

        let date = Date(isoDate: "2026-03-04")!

        @Test("Returns elapsed minutes in hours for a regular shift")
        func regularShift() {
            // Turno 1 Benidorm (2024): 05:20 → 13:54 = 8h 34m = 514 min → 8.57 h
            let start = date.settingTime(hour: 5, minute: 20)
            let end   = date.settingTime(hour: 13, minute: 54)
            let workDay = WorkDay(shift: "1", startDate: start, endDate: end, saturation: 41.87)
            #expect(workDay.workedTimeInHours == 8.57)
        }

        @Test("Returns 0 for SPP shifts")
        func sppShiftIsZero() {
            let start = date.settingTime(hour: 5, minute: 20)
            let end   = date.settingTime(hour: 13, minute: 54)
            let workDay = WorkDay(shift: "1", startDate: start, endDate: end, isSPP: true)
            #expect(workDay.workedTimeInHours == 0)
        }

        @Test("Returns consistent results for clean hour durations")
        func cleanHourDuration() {
            // 07:00 → 14:49 = 7h 49m = 469 min → 7.82 h
            let start = date.settingTime(hour: 7, minute: 0)
            let end   = date.settingTime(hour: 14, minute: 49)
            let workDay = WorkDay(shift: "STDR", startDate: start, endDate: end)
            #expect(workDay.workedTimeInHours == 7.82)
        }
    }

    // MARK: - sppMinutes

    @Suite("sppMinutes")
    struct SPPMinutesTests {

        let date = Date(isoDate: "2026-03-04")!

        @Test("Returns elapsed minutes for an SPP shift")
        func sppShift() {
            let start = date.settingTime(hour: 5, minute: 20)
            let end   = date.settingTime(hour: 13, minute: 54)
            let workDay = WorkDay(shift: "1", startDate: start, endDate: end, isSPP: true)
            #expect(workDay.sppMinutes == 514)
        }

        @Test("Returns 0 for a non-SPP shift")
        func nonSPPShift() {
            let start = date.settingTime(hour: 5, minute: 20)
            let end   = date.settingTime(hour: 13, minute: 54)
            let workDay = WorkDay(shift: "1", startDate: start, endDate: end)
            #expect(workDay.sppMinutes == 0)
        }
    }

    // MARK: - isStandardShift

    @Test("isStandardShift is true only for STDR shifts")
    func isStandardShift() {
        let start = date.settingTime(hour: 7, minute: 0)
        let end   = date.settingTime(hour: 14, minute: 49)
        let stdr    = WorkDay(shift: "STDR", startDate: start, endDate: end)
        let regular = WorkDay(shift: "1", startDate: start, endDate: end)
        #expect(stdr.isStandardShift)
        #expect(!regular.isStandardShift)
    }

    // MARK: - typeOfShift

    @Test("typeOfShift delegates correctly to TypeOfShift.determine",
          arguments: zip(
            [
                (Date(isoDate: "2026-03-04")!.settingTime(hour: 5, minute: 20),
                 Date(isoDate: "2026-03-04")!.settingTime(hour: 13, minute: 54)),
                (Date(isoDate: "2026-03-04")!.settingTime(hour: 11, minute: 52),
                 Date(isoDate: "2026-03-04")!.settingTime(hour: 19, minute: 36)),
                (Date(isoDate: "2026-03-04")!.settingTime(hour: 14, minute: 20),
                 Date(isoDate: "2026-03-04")!.settingTime(hour: 22, minute: 39)),
            ],
            [TypeOfShift.morning, TypeOfShift.noon, TypeOfShift.afternoon]
          )
    )
    func typeOfShift(times: (Date, Date), expected: TypeOfShift) {
        let workDay = WorkDay(shift: "1", startDate: times.0, endDate: times.1)
        #expect(workDay.typeOfShift == expected)
    }

    // MARK: - workDayNightTime

    @Suite("workDayNightTime")
    struct NightTimeTests {

        let date = Date(isoDate: "2026-03-04")!

        @Test("Early morning shift (05:00–13:00) has 1 hour of night time")
        func earlyMorningShift() {
            // Night period: 22:00–06:00. Shift overlaps 05:00–06:00 = 3600s
            let start   = date.settingTime(hour: 5, minute: 0)
            let end     = date.settingTime(hour: 13, minute: 0)
            let workDay = WorkDay(shift: "1", startDate: start, endDate: end)
            #expect(workDay.workDayNightTime == 3600)
        }

        @Test("Evening shift (14:00–23:00) has 1 hour of night time")
        func eveningShift() {
            // Night period: 22:00–06:00. Shift overlaps 22:00–23:00 = 3600s
            let start   = date.settingTime(hour: 14, minute: 0)
            let end     = date.settingTime(hour: 23, minute: 0)
            let workDay = WorkDay(shift: "4", startDate: start, endDate: end)
            #expect(workDay.workDayNightTime == 3600)
        }

        @Test("Daytime shift (07:00–15:00) has no night time")
        func dayShift() {
            let start   = date.settingTime(hour: 7, minute: 0)
            let end     = date.settingTime(hour: 15, minute: 0)
            let workDay = WorkDay(shift: "STDR", startDate: start, endDate: end)
            #expect(workDay.workDayNightTime == 0)
        }
    }
}
