//
//  ShiftsDataModel.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 21/3/24.
//

import SwiftUI

/// Classification of a shift based on its start and end times.
enum TypeOfShift: String, CaseIterable, Identifiable {
    case morning = "Mañana"
    case noon = "Intermedio"
    case afternoon = "Tarde"

    var id: Self { self }

    var color: Color {
        switch self {
        case .morning: .appYellow
        case .noon: .appOrange
        case .afternoon: .appBlue
        }
    }

    /// Determines the shift type from the elapsed seconds since midnight for the start and end times.
    ///
    /// - Parameters:
    ///   - startTime: Seconds since midnight for the shift start.
    ///   - endTime: Seconds since midnight for the shift end.
    /// - Returns: The matching ``TypeOfShift`` based on the thresholds defined in ``Constants``.
    static func determine(startTime: TimeInterval, endTime: TimeInterval) -> TypeOfShift {
        if startTime > Constants.morningStartHour && startTime < Constants.maxMorningStartHour && endTime < Constants.maxMorningEndHour {
            return .morning
        } else if startTime < Constants.maxMorningStartHour && endTime > Constants.maxMorningEndHour {
            return .noon
        } else {
            return .afternoon
        }
    }
}

/// Worker role within FGV operations.
enum Role: String, Identifiable, CaseIterable, PickerEnum {
    case maquinista
    case usi
    
    var id: Self { self }
    
    var displayName: String {
        switch self {
        case .maquinista: "Maquinista"
        case .usi: "USI"
        }
    }
}

/// Depot location where the worker is assigned.
enum Location: String, Identifiable, CaseIterable, PickerEnum {
    case benidorm
    case denia
    case campello
    
    var id: Self { self }
    
    var displayName: String { self.rawValue.capitalized }
}

/// A versioned collection of shifts applicable from a given date for a specific role and depot.
struct ShiftGroup: Identifiable {
    let id: UUID = .init()
    /// The date from which this group of shifts becomes effective.
    let validFrom: Date
    /// The worker role this group applies to.
    let role: Role
    /// The depot location this group applies to.
    let location: Location
    /// The list of shifts defined in this group.
    let shifts: [Shift]
}

/// Definition of a single shift schedule entry.
struct Shift: Identifiable {
    let id: UUID = .init()
    /// Display name / code of the shift (e.g. "1", "STDR", "A11").
    let name: String
    /// Start time expressed as seconds elapsed since midnight.
    let startTime: TimeInterval
    /// Total shift duration in seconds.
    let duration: TimeInterval
    /// Saturation bonus percentage. `nil` when no saturation applies.
    var saturation: Double?
}

/// Singleton data model that holds all hard-coded shift schedule definitions for every role, depot, and version.
struct ShiftsDataModel {
    static let shared = ShiftsDataModel()

    let shiftGroups = [
        // Maquinista Benidorm
        ShiftGroup(validFrom: Date(isoDate:"2023-07-14")!, role: .maquinista, location: .benidorm, shifts: [
            .init(name: "1", startTime: TimeInterval(hour: 5, minute: 27), duration: TimeInterval(hour: 8, minute: 9), saturation: 71.2),
            .init(name: "2", startTime: TimeInterval(hour: 6, minute: 27), duration: TimeInterval(hour: 8, minute: 9), saturation: 71.2),
            .init(name: "3", startTime: TimeInterval(hour: 11, minute: 52), duration: TimeInterval(hour: 7, minute: 44), saturation: 55.3),
            .init(name: "4", startTime: TimeInterval(hour: 13, minute: 52), duration: TimeInterval(hour: 8, minute: 59), saturation: 65.18),
            .init(name: "5", startTime: TimeInterval(hour: 14, minute: 52), duration: TimeInterval(hour: 8, minute: 23), saturation: 59.69),
            .init(name: "8", startTime: TimeInterval(hour: 5, minute: 45), duration: TimeInterval(hour: 7, minute: 15), saturation: 62.82),
            .init(name: "9", startTime: TimeInterval(hour: 13, minute: 45), duration: TimeInterval(hour: 7, minute: 15), saturation: 62.82),
            .init(name: "STDR", startTime: TimeInterval(hour: 7), duration: TimeInterval(hour: 7, minute: 49)),
            .init(name: "A1", startTime: TimeInterval(hour: 23, minute: 30), duration: TimeInterval(hour: 6), saturation: 57.14)
        ]),
        
        ShiftGroup(validFrom: Date(isoDate:"2024-04-09")!, role: .maquinista, location: .benidorm, shifts: [
            .init(name: "1", startTime: TimeInterval(hour: 5, minute: 20), duration: TimeInterval(hour: 8, minute: 34), saturation: 40.09),
            .init(name: "2", startTime: TimeInterval(hour: 6, minute: 20), duration: TimeInterval(hour: 8, minute: 34), saturation: 40.09),
            .init(name: "3", startTime: TimeInterval(hour: 13, minute: 45), duration: TimeInterval(hour: 9, minute: 8), saturation: 42.39),
            .init(name: "4", startTime: TimeInterval(hour: 14, minute: 45), duration: TimeInterval(hour: 8, minute: 31), saturation: 41.01),
            .init(name: "8", startTime: TimeInterval(hour: 5, minute: 45), duration: TimeInterval(hour: 6, minute: 45), saturation: 40.90),
            .init(name: "9", startTime: TimeInterval(hour: 13, minute: 45), duration: TimeInterval(hour: 6, minute: 45), saturation: 40.90),
            .init(name: "STDR", startTime: TimeInterval(hour: 7), duration: TimeInterval(hour: 7, minute: 49)),
            .init(name: "A11", startTime: TimeInterval(hour: 23, minute: 45), duration: TimeInterval(hour: 6, minute: 10), saturation: 66.67),
            .init(name: "A21", startTime: TimeInterval(hour: 19, minute: 16), duration: TimeInterval(hour: 5, minute: 46), saturation: 66.67),
            .init(name: "A22", startTime: TimeInterval(hour: 21, minute: 44), duration: TimeInterval(hour: 6, minute: 21), saturation: 66.67),
            .init(name: "A23", startTime: TimeInterval(hour: 22, minute: 2), duration: TimeInterval(hour: 6, minute: 37), saturation: 66.67),
            .init(name: "A24", startTime: TimeInterval(hour: 22, minute: 19), duration: TimeInterval(hour: 6, minute: 23), saturation: 66.67),
            .init(name: "A25", startTime: TimeInterval(hour: 0, minute: 40), duration: TimeInterval(hour: 5, minute: 17), saturation: 66.67),
        ]),
        
        ShiftGroup(validFrom: Date(isoDate:"2024-09-09")!, role: .maquinista, location: .benidorm, shifts: [
            .init(name: "1", startTime: TimeInterval(hour: 5, minute: 20), duration: TimeInterval(hour: 8, minute: 34), saturation: 41.87),
            .init(name: "2", startTime: TimeInterval(hour: 6, minute: 20), duration: TimeInterval(hour: 8, minute: 34), saturation: 41.87),
            .init(name: "3", startTime: TimeInterval(hour: 13, minute: 45), duration: TimeInterval(hour: 9, minute: 8), saturation: 44.02),
            .init(name: "4", startTime: TimeInterval(hour: 14, minute: 45), duration: TimeInterval(hour: 8, minute: 31), saturation: 42.76),
            .init(name: "8", startTime: TimeInterval(hour: 5, minute: 45), duration: TimeInterval(hour: 6, minute: 55), saturation: 40.90),
            .init(name: "9", startTime: TimeInterval(hour: 13, minute: 35), duration: TimeInterval(hour: 6, minute: 55), saturation: 40.90),
            .init(name: "STDR", startTime: TimeInterval(hour: 7), duration: TimeInterval(hour: 7, minute: 48)),
        ]),
        
        ShiftGroup(validFrom: Date(isoDate:"2025-01-28")!, role: .maquinista, location: .benidorm, shifts: [
            .init(name: "1", startTime: TimeInterval(hour: 5, minute: 5), duration: TimeInterval(hour: 6, minute: 20), saturation: 48.15),
            .init(name: "2", startTime: TimeInterval(hour: 5, minute: 15), duration: TimeInterval(hour: 7, minute: 24), saturation: 65.66),
            .init(name: "3", startTime: TimeInterval(hour: 6, minute: 20), duration: TimeInterval(hour: 8, minute: 19), saturation: 70.79),
            .init(name: "4", startTime: TimeInterval(hour: 9, minute: 20), duration: TimeInterval(hour: 8, minute: 19), saturation: 69.51),
            .init(name: "5", startTime: TimeInterval(hour: 14, minute: 20), duration: TimeInterval(hour: 8, minute: 19), saturation: 70.79),
            .init(name: "6", startTime: TimeInterval(hour: 17, minute: 9), duration: TimeInterval(hour: 6, minute: 20), saturation: 58.63),
            .init(name: "7", startTime: TimeInterval(hour: 15, minute: 20), duration: TimeInterval(hour: 8, minute: 19), saturation: 70.79),
            .init(name: "8", startTime: TimeInterval(hour: 5, minute: 10), duration: TimeInterval(hour: 8, minute: 35), saturation: 64.65),
            .init(name: "9", startTime: TimeInterval(hour: 14, minute: 10), duration: TimeInterval(hour: 8), saturation: 64.65),
            .init(name: "CI1", startTime: TimeInterval(hour: 6, minute: 30), duration: TimeInterval(hour: 7, minute: 46), saturation: 64.65),
            .init(name: "CI2", startTime: TimeInterval(hour: 15, minute: 30), duration: TimeInterval(hour: 7, minute: 46), saturation: 64.65),
            .init(name: "STDR", startTime: TimeInterval(hour: 7), duration: TimeInterval(hour: 7, minute: 46))
        ]),

        ShiftGroup(validFrom: Date(isoDate:"2025-07-04")!, role: .maquinista, location: .benidorm, shifts: [
            .init(name: "1", startTime: TimeInterval(hour: 5, minute: 5), duration: TimeInterval(hour: 8, minute: 34), saturation: 64.61),
            .init(name: "2", startTime: TimeInterval(hour: 7, minute: 20), duration: TimeInterval(hour: 8, minute: 19), saturation: 64.61),
            .init(name: "3", startTime: TimeInterval(hour: 6, minute: 5), duration: TimeInterval(hour: 8, minute: 34), saturation: 64.61),
            .init(name: "4", startTime: TimeInterval(hour: 14, minute: 20), duration: TimeInterval(hour: 8, minute: 19), saturation: 64.61),
            .init(name: "5", startTime: TimeInterval(hour: 16, minute: 20), duration: TimeInterval(hour: 7, minute: 9), saturation: 60.40),
            .init(name: "6", startTime: TimeInterval(hour: 15, minute: 20), duration: TimeInterval(hour: 8, minute: 19), saturation: 64.61),
            .init(name: "8", startTime: TimeInterval(hour: 5, minute: 10), duration: TimeInterval(hour: 8, minute: 35), saturation: 63.91),
            .init(name: "9", startTime: TimeInterval(hour: 14), duration: TimeInterval(hour: 8), saturation: 63.91),
            .init(name: "CI1", startTime: TimeInterval(hour: 6, minute: 30), duration: TimeInterval(hour: 7, minute: 46), saturation: 63.91),
            .init(name: "CI2", startTime: TimeInterval(hour: 15, minute: 30), duration: TimeInterval(hour: 7, minute: 46), saturation: 63.91),
            .init(name: "STDR", startTime: TimeInterval(hour: 7), duration: TimeInterval(hour: 7, minute: 46))
        ]),
        
        ShiftGroup(validFrom: Date(isoDate:"2025-08-01")!, role: .maquinista, location: .benidorm, shifts: [
            .init(name: "1", startTime: TimeInterval(hour: 5, minute: 5), duration: TimeInterval(hour: 6, minute: 20), saturation: 48.15),
            .init(name: "2", startTime: TimeInterval(hour: 5, minute: 15), duration: TimeInterval(hour: 7, minute: 24), saturation: 65.66),
            .init(name: "3", startTime: TimeInterval(hour: 6, minute: 20), duration: TimeInterval(hour: 8, minute: 19), saturation: 70.79),
            .init(name: "4", startTime: TimeInterval(hour: 9, minute: 20), duration: TimeInterval(hour: 8, minute: 19), saturation: 69.51),
            .init(name: "5", startTime: TimeInterval(hour: 14, minute: 20), duration: TimeInterval(hour: 8, minute: 19), saturation: 70.79),
            .init(name: "6", startTime: TimeInterval(hour: 17, minute: 9), duration: TimeInterval(hour: 6, minute: 20), saturation: 58.63),
            .init(name: "7", startTime: TimeInterval(hour: 15, minute: 20), duration: TimeInterval(hour: 8, minute: 19), saturation: 70.79),
            .init(name: "8", startTime: TimeInterval(hour: 5, minute: 10), duration: TimeInterval(hour: 8, minute: 35), saturation: 64.65),
            .init(name: "9", startTime: TimeInterval(hour: 14, minute: 10), duration: TimeInterval(hour: 8), saturation: 64.65),
            .init(name: "CI1", startTime: TimeInterval(hour: 6, minute: 30), duration: TimeInterval(hour: 7, minute: 46), saturation: 64.65),
            .init(name: "CI2", startTime: TimeInterval(hour: 15, minute: 30), duration: TimeInterval(hour: 7, minute: 46), saturation: 64.65),
            .init(name: "STDR", startTime: TimeInterval(hour: 7), duration: TimeInterval(hour: 7, minute: 46))
        ]),

        ShiftGroup(validFrom: Date(isoDate:"2026-01-08")!, role: .maquinista, location: .benidorm, shifts: [
            .init(name: "1", startTime: TimeInterval(hour: 5, minute: 5), duration: TimeInterval(hour: 6, minute: 20), saturation: 48.15),
            .init(name: "2", startTime: TimeInterval(hour: 5, minute: 15), duration: TimeInterval(hour: 7, minute: 24), saturation: 65.66),
            .init(name: "3", startTime: TimeInterval(hour: 6, minute: 20), duration: TimeInterval(hour: 8, minute: 19), saturation: 70.79),
            .init(name: "4", startTime: TimeInterval(hour: 9, minute: 20), duration: TimeInterval(hour: 8, minute: 19), saturation: 69.51),
            .init(name: "5", startTime: TimeInterval(hour: 14, minute: 20), duration: TimeInterval(hour: 8, minute: 19), saturation: 70.79),
            .init(name: "6", startTime: TimeInterval(hour: 17, minute: 9), duration: TimeInterval(hour: 6, minute: 20), saturation: 58.63),
            .init(name: "7", startTime: TimeInterval(hour: 15, minute: 20), duration: TimeInterval(hour: 8, minute: 19), saturation: 70.79),
            .init(name: "8", startTime: TimeInterval(hour: 5, minute: 05), duration: TimeInterval(hour: 8, minute: 35), saturation: 64.65),
            .init(name: "9", startTime: TimeInterval(hour: 14, minute: 05), duration: TimeInterval(hour: 8), saturation: 64.65),
            .init(name: "CI1", startTime: TimeInterval(hour: 6, minute: 30), duration: TimeInterval(hour: 7, minute: 46), saturation: 64.65),
            .init(name: "CI2", startTime: TimeInterval(hour: 15, minute: 30), duration: TimeInterval(hour: 7, minute: 46), saturation: 64.65),
            .init(name: "STDR", startTime: TimeInterval(hour: 7), duration: TimeInterval(hour: 7, minute: 46))
        ]),

        // Maquinista Denia
        ShiftGroup(validFrom: Date(isoDate:"2023-07-14")!, role: .maquinista, location: .denia, shifts: [
            .init(name: "21", startTime: TimeInterval(hour: 5, minute: 5), duration: TimeInterval(hour: 7, minute: 52), saturation: 59.25),
            .init(name: "22", startTime: TimeInterval(hour: 5, minute: 20), duration: TimeInterval(hour: 8, minute: 37), saturation: 64.41),
            .init(name: "23", startTime: TimeInterval(hour: 9, minute: 35), duration: TimeInterval(hour: 7, minute: 22), saturation: 66.26),
            .init(name: "24", startTime: TimeInterval(hour: 14, minute: 35), duration: TimeInterval(hour: 8, minute: 22), saturation: 51.48),
            .init(name: "25", startTime: TimeInterval(hour: 16, minute: 35), duration: TimeInterval(hour: 6, minute: 36), saturation: 58.20),
            .init(name: "26", startTime: TimeInterval(hour: 5, minute: 15), duration: TimeInterval(hour: 7, minute: 15), saturation: 60.72),
            .init(name: "27", startTime: TimeInterval(hour: 14, minute: 45), duration: TimeInterval(hour: 7), saturation: 60.72)
        ]),
        
        ShiftGroup(validFrom: Date(isoDate:"2024-04-09")!, role: .maquinista, location: .denia, shifts: [
            .init(name: "21", startTime: TimeInterval(hour: 5, minute: 5), duration: TimeInterval(hour: 7, minute: 2), saturation: 64.03),
            .init(name: "22", startTime: TimeInterval(hour: 5, minute: 20), duration: TimeInterval(hour: 7, minute: 47), saturation: 66.26),
            .init(name: "23", startTime: TimeInterval(hour: 8, minute: 35), duration: TimeInterval(hour: 7, minute: 32), saturation: 66.26),
            .init(name: "24", startTime: TimeInterval(hour: 12, minute: 35), duration: TimeInterval(hour: 7, minute: 32), saturation: 66.26),
            .init(name: "25", startTime: TimeInterval(hour: 15, minute: 35), duration: TimeInterval(hour: 7, minute: 32), saturation: 66.26),
            .init(name: "26", startTime: TimeInterval(hour: 16, minute: 35), duration: TimeInterval(hour: 6, minute: 46), saturation: 63.93),
            .init(name: "27", startTime: TimeInterval(hour: 5, minute: 5), duration: TimeInterval(hour: 8, minute: 10), saturation: 65.50),
            .init(name: "28", startTime: TimeInterval(hour: 13, minute: 30), duration: TimeInterval(hour: 8, minute: 15), saturation: 65.50),
        ]),
        
        ShiftGroup(validFrom: Date(isoDate:"2024-09-09")!, role: .maquinista, location: .denia, shifts: [
            .init(name: "21", startTime: TimeInterval(hour: 5, minute: 5), duration: TimeInterval(hour: 6, minute: 52), saturation: 64.03),
            .init(name: "22", startTime: TimeInterval(hour: 5, minute: 20), duration: TimeInterval(hour: 7, minute: 37), saturation: 66.26),
            .init(name: "23", startTime: TimeInterval(hour: 8, minute: 35), duration: TimeInterval(hour: 7, minute: 22), saturation: 66.26),
            .init(name: "24", startTime: TimeInterval(hour: 12, minute: 35), duration: TimeInterval(hour: 7, minute: 22), saturation: 66.26),
            .init(name: "25", startTime: TimeInterval(hour: 15, minute: 35), duration: TimeInterval(hour: 7, minute: 22), saturation: 66.26),
            .init(name: "26", startTime: TimeInterval(hour: 16, minute: 35), duration: TimeInterval(hour: 6, minute: 36), saturation: 63.93),
            .init(name: "27", startTime: TimeInterval(hour: 5, minute: 5), duration: TimeInterval(hour: 8, minute: 30), saturation: 65.50),
            .init(name: "28", startTime: TimeInterval(hour: 13, minute: 30), duration: TimeInterval(hour: 8, minute: 30), saturation: 65.50),
        ]),
        
        ShiftGroup(validFrom: Date(isoDate:"2025-01-28")!, role: .maquinista, location: .denia, shifts: [
            .init(name: "21", startTime: TimeInterval(hour: 5, minute: 32), duration: TimeInterval(hour: 7, minute: 39), saturation: 65.70),
            .init(name: "22", startTime: TimeInterval(hour: 9, minute: 47), duration: TimeInterval(hour: 8, minute: 24), saturation: 70.04),
            .init(name: "23", startTime: TimeInterval(hour: 14, minute: 47), duration: TimeInterval(hour: 8, minute: 24), saturation: 70.04),
            .init(name: "24", startTime: TimeInterval(hour: 5, minute: 35), duration: TimeInterval(hour: 7, minute: 35), saturation: 68.59),
            .init(name: "25", startTime: TimeInterval(hour: 14, minute: 30), duration: TimeInterval(hour: 7, minute: 35), saturation: 68.59),
            .init(name: "SP1", startTime: TimeInterval(hour: 5, minute: 15), duration: TimeInterval(hour: 7, minute: 43), saturation: 68.59),
            .init(name: "SP2", startTime: TimeInterval(hour: 14, minute: 15), duration: TimeInterval(hour: 7, minute: 43), saturation: 68.59),
        ]),

        ShiftGroup(validFrom: Date(isoDate:"2025-07-04")!, role: .maquinista, location: .denia, shifts: [
            .init(name: "21", startTime: TimeInterval(hour: 5, minute: 15), duration: TimeInterval(hour: 8, minute: 14), saturation: 46.33),
            .init(name: "22", startTime: TimeInterval(hour: 6, minute: 15), duration: TimeInterval(hour: 8, minute: 14), saturation: 46.33),
            .init(name: "23", startTime: TimeInterval(hour: 13, minute: 30), duration: TimeInterval(hour: 8, minute: 59), saturation: 46.56),
            .init(name: "24", startTime: TimeInterval(hour: 5, minute: 32), duration: TimeInterval(hour: 7, minute: 40), saturation: 45.83),
            .init(name: "25", startTime: TimeInterval(hour: 14, minute: 30), duration: TimeInterval(hour: 6, minute: 30), saturation: 46.26),
            .init(name: "SP1", startTime: TimeInterval(hour: 5, minute: 15), duration: TimeInterval(hour: 7, minute: 43), saturation: 68.59),
            .init(name: "SP2", startTime: TimeInterval(hour: 14, minute: 15), duration: TimeInterval(hour: 7, minute: 43), saturation: 68.59),
        ]),

        ShiftGroup(validFrom: Date(isoDate:"2025-08-01")!, role: .maquinista, location: .denia, shifts: [
            .init(name: "21", startTime: TimeInterval(hour: 5, minute: 32), duration: TimeInterval(hour: 7, minute: 39), saturation: 65.70),
            .init(name: "22", startTime: TimeInterval(hour: 9, minute: 47), duration: TimeInterval(hour: 8, minute: 24), saturation: 70.04),
            .init(name: "23", startTime: TimeInterval(hour: 14, minute: 47), duration: TimeInterval(hour: 8, minute: 24), saturation: 70.04),
            .init(name: "24", startTime: TimeInterval(hour: 5, minute: 35), duration: TimeInterval(hour: 7, minute: 35), saturation: 68.59),
            .init(name: "25", startTime: TimeInterval(hour: 14, minute: 30), duration: TimeInterval(hour: 7, minute: 35), saturation: 68.59),
            .init(name: "SP1", startTime: TimeInterval(hour: 5, minute: 15), duration: TimeInterval(hour: 7, minute: 43), saturation: 68.59),
            .init(name: "SP2", startTime: TimeInterval(hour: 14, minute: 15), duration: TimeInterval(hour: 7, minute: 43), saturation: 68.59),
        ]),
    ]
    
    /// Returns the shift groups that are valid on the given date for the current user's role, one per depot location.
    ///
    /// - Parameter date: The reference date used to select the most recent applicable group.
    /// - Returns: An array of ``ShiftGroup`` values — at most one per ``Location``.
    func shiftsGroupsValidsTo(_ date: Date) -> [ShiftGroup] {
        let role = NSUbiquitousKeyValueStore.default.string(forKey: "role") ?? ""
        let sortedShiftGroups = shiftGroups.sorted().reversed()
        var actualShiftGroups: [ShiftGroup] = []
        
        for location in Location.allCases {
            if let shiftGroup = sortedShiftGroups.first(where: { $0.validFrom <= date && $0.role.rawValue == role && $0.location == location }) {
                actualShiftGroups.append(shiftGroup)
            }
        }
        
        return actualShiftGroups
    }
    
    /// Returns the current shifts grouped by depot display name for the given date.
    ///
    /// - Parameter date: The reference date used to resolve the active shift groups.
    /// - Returns: A dictionary mapping each depot's display name to its sorted list of ``Shift`` values.
    func getActualShiftsByLocation(_ date: Date) -> [String: [Shift]] {
        var shiftsByLocation: [String: [Shift]] = [:]
        
        let currentShiftGroups = shiftsGroupsValidsTo(date)
        
        for shiftGroup in currentShiftGroups {
            shiftsByLocation[shiftGroup.location.displayName, default: []].append(contentsOf: shiftGroup.shifts.sorted())
        }
        
        return shiftsByLocation
    }
    
    func shiftGroup(for shiftId: Shift.ID) -> ShiftGroup? {
        shiftGroups.first(where: { $0.shifts.contains(where: { $0.id == shiftId }) })
    }
    
    func shiftLocation(for shiftId: Shift.ID) -> Location? {
        let shiftGroup = shiftGroup(for: shiftId)
        return shiftGroup?.location
    }
    
    /// Returns the duration in minutes of the standard STDR shift valid for the given date.
    ///
    /// - Parameter date: The work date used to look up the active shift group.
    /// - Returns: The STDR shift duration in minutes, or `0` if no matching group is found.
    func standardMinutesFor(date: Date) -> Int {
        let shiftGroups = shiftsGroupsValidsTo(date)

        for shiftGroup in shiftGroups {
            if let standardShift = shiftGroup.shifts.first(where: { $0.name == "STDR" }) {
                return standardShift.duration.inMinutes
            }
        }

        return 0
    }
}

extension Dictionary where Key == String, Value == [Shift] {
    /// Returns whether the given shift belongs to the user's assigned depot.
    ///
    /// - Parameters:
    ///   - shift: The shift to look up.
    ///   - userLocation: The raw value of the user's ``Location``.
    /// - Returns: `true` when the shift is listed under the user's depot in this dictionary.
    func isFromUserLocation(_ shift: Shift, userLocation: String) -> Bool {
        let userLocationName = Location(rawValue: userLocation)?.displayName ?? ""
        return self[userLocationName]?.contains { $0.id == shift.id } ?? false
    }
}
