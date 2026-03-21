//
//  NewRecordViewModel.swift
//  TurnosFGV
//

import Foundation

@MainActor
@Observable
final class NewRecordViewModel {
    let date: Date
    private let repository: any WorkDayRepository
    private let shiftGroups = ShiftsDataModel.shared

    private(set) var shiftsByLocation: [String: [Shift]] = [:]
    var selectedShift: Shift?
    let draft: WorkDay

    init(date: Date, repository: any WorkDayRepository) {
        self.date = date
        self.repository = repository
        self.draft = WorkDay(shift: "", startDate: date, endDate: date)
    }

    var canSave: Bool { selectedShift != nil }

    func loadShifts() {
        shiftsByLocation = shiftGroups.getActualShiftsByLocation(date)
    }

    func onShiftSelected(userLocation: String) {
        guard let selectedShift else { return }
        draft.shift = selectedShift.name
        draft.startDate = date.startOfDay.addingTimeInterval(selectedShift.startTime)
        draft.endDate = draft.startDate.addingTimeInterval(selectedShift.duration)
        draft.saturation = selectedShift.saturation
        draft.isAllowance = !shiftsByLocation.isFromUserLocation(selectedShift, userLocation: userLocation)
    }

    func save() {
        guard canSave else { return }
        repository.insert(draft)
    }
}
