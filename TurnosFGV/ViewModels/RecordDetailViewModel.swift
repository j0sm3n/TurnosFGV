//
//  RecordDetailViewModel.swift
//  TurnosFGV
//

import Foundation

@MainActor
@Observable
final class RecordDetailViewModel {
    private let repository: any WorkDayRepository
    private let shiftGroups = ShiftsDataModel.shared

    let workDay: WorkDay
    let updateWorkDay: WorkDay

    var shift: Shift?
    private(set) var shiftsByLocation: [String: [Shift]] = [:]
    var showDeleteAlert: Bool = false

    init(workDay: WorkDay, repository: any WorkDayRepository) {
        self.workDay = workDay
        self.repository = repository
        self.updateWorkDay = workDay.copy()
    }

    var locations: [String] { shiftsByLocation.keys.sorted(by: <) }
    var shifts: [Shift] { locations.flatMap { shiftsByLocation[$0] ?? [] } }

    func loadShifts() {
        shiftsByLocation = shiftGroups.getActualShiftsByLocation(workDay.startDate)
        shift = shifts.first(where: { $0.name == updateWorkDay.shift })
    }

    func updateRecord() {
        workDay.shift = updateWorkDay.shift
        workDay.startDate = updateWorkDay.startDate
        workDay.endDate = updateWorkDay.endDate
        workDay.saturation = updateWorkDay.saturation
        workDay.extraTime = updateWorkDay.extraTime
        workDay.isAllowance = updateWorkDay.isAllowance
        workDay.isFreeLicense = updateWorkDay.isFreeLicense
        workDay.isWorkedHoliday = updateWorkDay.isWorkedHoliday
        workDay.isSpecialWorkedHoliday = updateWorkDay.isSpecialWorkedHoliday
        workDay.isMentoring = updateWorkDay.isMentoring
        workDay.isPaidLicense = updateWorkDay.isPaidLicense
        workDay.isSickLeave = updateWorkDay.isSickLeave
        workDay.isWorkAccident = updateWorkDay.isWorkAccident
        workDay.isSPP = updateWorkDay.isSPP
    }

    func deleteRecord() {
        repository.delete(workDay)
    }

    func onShiftChanged(userLocation: String) {
        guard let shift, updateWorkDay.shift != shift.name else { return }
        updateWorkDay.shift = shift.name
        updateWorkDay.startDate = updateWorkDay.startDate.startOfDay.addingTimeInterval(shift.startTime)
        updateWorkDay.endDate = updateWorkDay.startDate.addingTimeInterval(shift.duration)
        updateWorkDay.saturation = shift.saturation
        updateWorkDay.extraTime = 0
        updateWorkDay.isAllowance = !shiftsByLocation.isFromUserLocation(shift, userLocation: userLocation)
    }
}
