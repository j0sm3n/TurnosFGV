//
//  VersionedSchemaV1.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 21/3/24.
//

import Foundation
import SwiftData

/// First version of the app's SwiftData schema (1.0.0).
enum VersionedSchemaV1: VersionedSchema {
    static var models: [any PersistentModel.Type] {
        [WorkDay.self]
    }

    static var versionIdentifier: Schema.Version = .init(1, 0, 0)
}

extension VersionedSchemaV1 {
    /// Persistent record representing a single work shift at FGV.
    @Model
    final class WorkDay {
        /// Shift code identifier (e.g. "1", "STDR", "A11").
        var shift: String = ""
        /// Date and time when the shift starts.
        var startDate: Date = Date.now
        /// Date and time when the shift ends.
        var endDate: Date = Date.now
        /// Saturation bonus percentage (`prima de saturación`). `nil` when the shift carries no saturation.
        var saturation: Double?
        /// Overtime beyond the standard shift duration, expressed in minutes.
        var extraTime: Int = 0
        /// Whether the worker receives a meal allowance (dieta) for this shift.
        var isAllowance: Bool = false
        /// Whether the shift corresponds to unpaid leave (licencia sin sueldo).
        var isFreeLicense: Bool = false
        /// Whether a standard public holiday was worked.
        var isWorkedHoliday: Bool = false
        /// Whether a special public holiday was worked (carrying additional compensation).
        var isSpecialWorkedHoliday: Bool = false
        /// Whether the shift includes mentoring or tutoring of another driver.
        var isMentoring: Bool = false
        /// Whether the shift corresponds to paid leave (licencia retribuida).
        var isPaidLicense: Bool = false
        /// Whether the worker is on sick leave (baja por enfermedad común).
        var isSickLeave: Bool = false
        /// Whether the worker is on leave due to a work accident (accidente laboral).
        var isWorkAccident: Bool = false
        /// Whether the shift is covered by the in-house prevention service (Servicio de Prevención Propio).
        var isSPP: Bool = false

        init(
            shift: String,
            startDate: Date,
            endDate: Date,
            saturation: Double? = nil,
            extraTime: Int = 0,
            isAllowance: Bool = false,
            isFreeLicense: Bool = false,
            isWorkedHoliday: Bool = false,
            isSpecialWorkedHoliday: Bool = false,
            isMentoring: Bool = false,
            isPaidLicense: Bool = false,
            isSickLeave: Bool = false,
            isWorkAccident: Bool = false,
            isSPP: Bool = false
        ) {
            self.shift = shift
            self.startDate = startDate
            self.endDate = endDate
            self.saturation = saturation
            self.extraTime = extraTime
            self.isAllowance = isAllowance
            self.isFreeLicense = isFreeLicense
            self.isWorkedHoliday = isWorkedHoliday
            self.isSpecialWorkedHoliday = isSpecialWorkedHoliday
            self.isMentoring = isMentoring
            self.isPaidLicense = isPaidLicense
            self.isSickLeave = isSickLeave
            self.isWorkAccident = isWorkAccident
            self.isSPP = isSPP
        }
    }
}
