//
//  VersionedSchemaV1.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 21/3/24.
//

import Foundation
import SwiftData

enum VersionedSchemaV1: VersionedSchema {
    static var models: [any PersistentModel.Type] {
        [WorkDay.self]
    }
    
    static var versionIdentifier: Schema.Version = .init(1, 0, 0)
}

extension VersionedSchemaV1 {
    @Model
    final class WorkDay {
        var shift: String = ""
        var startDate: Date = Date.now
        var endDate: Date = Date.now
        var saturation: Double?
        var extraTime: Int = 0
        var isAllowance: Bool = false
        var isFreeLicense: Bool = false
        var isWorkedHoliday: Bool = false
        var isSpecialWorkedHoliday: Bool = false
        var isMentoring: Bool = false
        var isPaidLicense: Bool = false
        var isSickLeave: Bool = false
        var isWorkAccident: Bool = false
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
