//
//  PayrollViewModelTests.swift
//  TurnosFGVTests
//

import Foundation
import SwiftData
import Testing
@testable import TurnosFGV

@Suite("PayrollViewModel")
struct PayrollViewModelTests {

    let container: ModelContainer
    let context: ModelContext
    let viewModel: PayrollViewModel

    init() throws {
        container = try ModelContainer(
            for: WorkDay.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        context = ModelContext(container)
        viewModel = PayrollViewModel()
    }

    // MARK: - Helpers

    private func insertWorkDay(
        shift: String = "1",
        on date: Date,
        startHour: Int = 5,
        durationHours: Int = 8,
        saturation: Double? = nil,
        isSPP: Bool = false,
        isSickLeave: Bool = false,
        isAllowance: Bool = false,
        isWorkedHoliday: Bool = false,
        isSpecialWorkedHoliday: Bool = false
    ) {
        let start = date.settingTime(hour: startHour, minute: 0)
        let end = start.addingTimeInterval(TimeInterval(hour: durationHours))
        let day = WorkDay(
            shift: shift,
            startDate: start,
            endDate: end,
            saturation: saturation,
            isAllowance: isAllowance,
            isWorkedHoliday: isWorkedHoliday,
            isSpecialWorkedHoliday: isSpecialWorkedHoliday,
            isSickLeave: isSickLeave,
            isSPP: isSPP
        )
        context.insert(day)
    }

    private func loadMarch() {
        viewModel.selectedDate = Date(isoDate: "2026-03-15")!
        viewModel.load(from: context)
    }

    // MARK: - recordsInMonth

    @Test("recordsInMonth includes only WorkDays within the selected month")
    func recordsInMonthFilter() {
        insertWorkDay(on: Date(isoDate: "2026-03-10")!)
        insertWorkDay(on: Date(isoDate: "2026-02-20")!)  // previous month
        insertWorkDay(on: Date(isoDate: "2026-04-01")!)  // next month
        loadMarch()

        #expect(viewModel.recordsInMonth.count == 1)
        #expect(viewModel.workDays.count == 3)
    }

    // MARK: - workedDaysInCurrentMonth

    @Test("workedDaysInCurrentMonth excludes SPP records")
    func workedDaysExcludesSPP() {
        let march = Date(isoDate: "2026-03-10")!
        insertWorkDay(on: march)
        insertWorkDay(on: march.adding(1, .day), isSPP: true)
        insertWorkDay(on: march.adding(2, .day))
        loadMarch()

        #expect(viewModel.workedDaysInCurrentMonth == 2)
    }

    // MARK: - monthWorkedHours

    @Test("monthWorkedHours sums hours of non-SPP records")
    func monthWorkedHours() {
        let march = Date(isoDate: "2026-03-10")!
        insertWorkDay(on: march, durationHours: 8)
        insertWorkDay(on: march.adding(1, .day), durationHours: 8)
        loadMarch()

        #expect(viewModel.monthWorkedHours == 16.0)
    }

    // MARK: - saturationInMonth

    @Test("saturationInMonth sums saturation from non-sick records")
    func saturationInMonth() {
        let march = Date(isoDate: "2026-03-10")!
        insertWorkDay(on: march, saturation: 40.0)
        insertWorkDay(on: march.adding(1, .day), saturation: 50.0)
        loadMarch()

        #expect(viewModel.saturationInMonth == 90.0)
    }

    @Test("saturationInMonth excludes sick-leave records")
    func saturationExcludesSickLeave() {
        let march = Date(isoDate: "2026-03-10")!
        insertWorkDay(on: march, saturation: 40.0)
        insertWorkDay(on: march.adding(1, .day), saturation: 50.0, isSickLeave: true)
        loadMarch()

        #expect(viewModel.saturationInMonth == 40.0)
    }

    // MARK: - nightTimeInMonth

    @Test("nightTimeInMonth sums nocturnidad hours (05:00–13:00 → 1h night)")
    func nightTimeInMonth() {
        let march = Date(isoDate: "2026-03-10")!
        // 05:00–13:00: night overlap 05:00–06:00 = 3600s = 1.0 h
        insertWorkDay(on: march, startHour: 5, durationHours: 8)
        loadMarch()

        #expect(viewModel.nightTimeInMonth == 1.0)
    }

    // MARK: - numberOfAllowance

    @Test("numberOfAllowance returns total allowance in euros")
    func numberOfAllowance() {
        let march = Date(isoDate: "2026-03-10")!
        insertWorkDay(on: march, isAllowance: true)
        insertWorkDay(on: march.adding(1, .day), isAllowance: true)
        insertWorkDay(on: march.adding(2, .day), isAllowance: false)
        loadMarch()

        #expect(viewModel.numberOfAllowance == Double(2) * Constants.allowanceValue)
    }

    // MARK: - snackBreakCompensation

    @Test("snackBreakCompensation counts non-STDR non-sick records")
    func snackBreakCompensation() {
        let march = Date(isoDate: "2026-03-10")!
        insertWorkDay(shift: "1", on: march)                        // counts
        insertWorkDay(shift: "STDR", on: march.adding(1, .day)) // does NOT count
        insertWorkDay(shift: "2", on: march.adding(2, .day))    // counts
        loadMarch()

        #expect(viewModel.snackBreakCompensation == 2)
    }

    // MARK: - recordsInYear

    @Test("recordsInYear includes all WorkDays in the selected calendar year")
    func recordsInYear() {
        insertWorkDay(on: Date(isoDate: "2026-03-10")!)
        insertWorkDay(on: Date(isoDate: "2025-12-31")!) // previous year
        insertWorkDay(on: Date(isoDate: "2027-01-01")!) // next year
        loadMarch()

        #expect(viewModel.recordsInYear.count == 1)
    }

    @Test("workedDaysInCurrentYear counts all records in the year")
    func workedDaysInCurrentYear() {
        let march = Date(isoDate: "2026-03-10")!
        insertWorkDay(on: march)
        insertWorkDay(on: march.adding(2, .month))  // May 2026 – same year
        loadMarch()

        #expect(viewModel.workedDaysInCurrentYear == 2)
    }
}
