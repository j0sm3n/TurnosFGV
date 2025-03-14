//
//  ShiftsDataModel.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 21/3/24.
//

import DateHelper
import SwiftUI

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
}

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

enum Location: String, Identifiable, CaseIterable, PickerEnum {
    case benidorm
    case denia
    case campello
    
    var id: Self { self }
    
    var displayName: String { self.rawValue.capitalized }
}

struct ShiftGroup: Identifiable {
    let id: UUID = .init()
    let validFrom: Date
    let role: Role
    let location: Location
    let shifts: [Shift]
}

struct Shift: Identifiable {
    let id: UUID = .init()
    let name: String
    let startTime: TimeInterval
    let duration: TimeInterval
    var saturation: Double?
}

// Data Model
struct ShiftsDataModel {
    let shiftGroups = [
        // Maquinista Benidorm
        ShiftGroup(validFrom: .init(fromString: "2023-07-14", format: .isoDate)!, role: .maquinista, location: .benidorm, shifts: [
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
        
        ShiftGroup(validFrom: .init(fromString: "2024-04-09", format: .isoDate)!, role: .maquinista, location: .benidorm, shifts: [
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
        
        ShiftGroup(validFrom: .init(fromString: "2024-09-09", format: .isoDate)!, role: .maquinista, location: .benidorm, shifts: [
            .init(name: "1", startTime: TimeInterval(hour: 5, minute: 20), duration: TimeInterval(hour: 8, minute: 34), saturation: 41.87),
            .init(name: "2", startTime: TimeInterval(hour: 6, minute: 20), duration: TimeInterval(hour: 8, minute: 34), saturation: 41.87),
            .init(name: "3", startTime: TimeInterval(hour: 13, minute: 45), duration: TimeInterval(hour: 9, minute: 8), saturation: 44.02),
            .init(name: "4", startTime: TimeInterval(hour: 14, minute: 45), duration: TimeInterval(hour: 8, minute: 31), saturation: 42.76),
            .init(name: "8", startTime: TimeInterval(hour: 5, minute: 45), duration: TimeInterval(hour: 6, minute: 55), saturation: 40.90),
            .init(name: "9", startTime: TimeInterval(hour: 13, minute: 35), duration: TimeInterval(hour: 6, minute: 55), saturation: 40.90),
            // It is mandatory to update Constants.standardWorkDayMinutes
            .init(name: "STDR", startTime: TimeInterval(hour: 7), duration: TimeInterval(hour: 7, minute: 48)),
        ]),
        
        ShiftGroup(validFrom: .init(fromString: "2025-01-28", format: .isoDate)!, role: .maquinista, location: .benidorm, shifts: [
            .init(name: "1", startTime: TimeInterval(hour: 5, minute: 5), duration: TimeInterval(hour: 6, minute: 20), saturation: 48.15),
            .init(name: "2", startTime: TimeInterval(hour: 5, minute: 15), duration: TimeInterval(hour: 7, minute: 24), saturation: 65.66),
            .init(name: "3", startTime: TimeInterval(hour: 6, minute: 20), duration: TimeInterval(hour: 8, minute: 19), saturation: 70.79),
            .init(name: "4", startTime: TimeInterval(hour: 9, minute: 20), duration: TimeInterval(hour: 8, minute: 19), saturation: 69.51),
            .init(name: "5", startTime: TimeInterval(hour: 14, minute: 20), duration: TimeInterval(hour: 8, minute: 19), saturation: 70.79),
            .init(name: "6", startTime: TimeInterval(hour: 17, minute: 9), duration: TimeInterval(hour: 6, minute: 20), saturation: 58.63),
            .init(name: "7", startTime: TimeInterval(hour: 15, minute: 20), duration: TimeInterval(hour: 8, minute: 19), saturation: 70.79),
            .init(name: "8", startTime: TimeInterval(hour: 5, minute: 10), duration: TimeInterval(hour: 8, minute: 35), saturation: 64.65),
            .init(name: "9", startTime: TimeInterval(hour: 14, minute: 10), duration: TimeInterval(hour: 8), saturation: 64.65),
            .init(name: "STDR", startTime: TimeInterval(hour: 7), duration: TimeInterval(hour: 7, minute: 46))
        ]),
        
        // Maquinista Denia
        ShiftGroup(validFrom: .init(fromString: "2023-07-14", format: .isoDate)!, role: .maquinista, location: .denia, shifts: [
            .init(name: "21", startTime: TimeInterval(hour: 5, minute: 5), duration: TimeInterval(hour: 7, minute: 52), saturation: 59.25),
            .init(name: "22", startTime: TimeInterval(hour: 5, minute: 20), duration: TimeInterval(hour: 8, minute: 37), saturation: 64.41),
            .init(name: "23", startTime: TimeInterval(hour: 9, minute: 35), duration: TimeInterval(hour: 7, minute: 22), saturation: 66.26),
            .init(name: "24", startTime: TimeInterval(hour: 14, minute: 35), duration: TimeInterval(hour: 8, minute: 22), saturation: 51.48),
            .init(name: "25", startTime: TimeInterval(hour: 16, minute: 35), duration: TimeInterval(hour: 6, minute: 36), saturation: 58.20),
            .init(name: "26", startTime: TimeInterval(hour: 5, minute: 15), duration: TimeInterval(hour: 7, minute: 15), saturation: 60.72),
            .init(name: "27", startTime: TimeInterval(hour: 14, minute: 45), duration: TimeInterval(hour: 7), saturation: 60.72)
        ]),
        
        ShiftGroup(validFrom: .init(fromString: "2024-04-09", format: .isoDate)!, role: .maquinista, location: .denia, shifts: [
            .init(name: "21", startTime: TimeInterval(hour: 5, minute: 5), duration: TimeInterval(hour: 7, minute: 2), saturation: 64.03),
            .init(name: "22", startTime: TimeInterval(hour: 5, minute: 20), duration: TimeInterval(hour: 7, minute: 47), saturation: 66.26),
            .init(name: "23", startTime: TimeInterval(hour: 8, minute: 35), duration: TimeInterval(hour: 7, minute: 32), saturation: 66.26),
            .init(name: "24", startTime: TimeInterval(hour: 12, minute: 35), duration: TimeInterval(hour: 7, minute: 32), saturation: 66.26),
            .init(name: "25", startTime: TimeInterval(hour: 15, minute: 35), duration: TimeInterval(hour: 7, minute: 32), saturation: 66.26),
            .init(name: "26", startTime: TimeInterval(hour: 16, minute: 35), duration: TimeInterval(hour: 6, minute: 46), saturation: 63.93),
            .init(name: "27", startTime: TimeInterval(hour: 5, minute: 5), duration: TimeInterval(hour: 8, minute: 10), saturation: 65.50),
            .init(name: "28", startTime: TimeInterval(hour: 13, minute: 30), duration: TimeInterval(hour: 8, minute: 15), saturation: 65.50),
        ]),
        
        ShiftGroup(validFrom: .init(fromString: "2024-09-09", format: .isoDate)!, role: .maquinista, location: .denia, shifts: [
            .init(name: "21", startTime: TimeInterval(hour: 5, minute: 5), duration: TimeInterval(hour: 6, minute: 52), saturation: 64.03),
            .init(name: "22", startTime: TimeInterval(hour: 5, minute: 20), duration: TimeInterval(hour: 7, minute: 37), saturation: 66.26),
            .init(name: "23", startTime: TimeInterval(hour: 8, minute: 35), duration: TimeInterval(hour: 7, minute: 22), saturation: 66.26),
            .init(name: "24", startTime: TimeInterval(hour: 12, minute: 35), duration: TimeInterval(hour: 7, minute: 22), saturation: 66.26),
            .init(name: "25", startTime: TimeInterval(hour: 15, minute: 35), duration: TimeInterval(hour: 7, minute: 22), saturation: 66.26),
            .init(name: "26", startTime: TimeInterval(hour: 16, minute: 35), duration: TimeInterval(hour: 6, minute: 36), saturation: 63.93),
            .init(name: "27", startTime: TimeInterval(hour: 5, minute: 5), duration: TimeInterval(hour: 8, minute: 30), saturation: 65.50),
            .init(name: "28", startTime: TimeInterval(hour: 13, minute: 30), duration: TimeInterval(hour: 8, minute: 30), saturation: 65.50),
        ]),
        
        ShiftGroup(validFrom: .init(fromString: "2025-01-28", format: .isoDate)!, role: .maquinista, location: .denia, shifts: [
            .init(name: "21", startTime: TimeInterval(hour: 5, minute: 32), duration: TimeInterval(hour: 7, minute: 39), saturation: 65.70),
            .init(name: "22", startTime: TimeInterval(hour: 9, minute: 47), duration: TimeInterval(hour: 8, minute: 24), saturation: 70.04),
            .init(name: "23", startTime: TimeInterval(hour: 14, minute: 47), duration: TimeInterval(hour: 8, minute: 24), saturation: 70.04),
            .init(name: "24", startTime: TimeInterval(hour: 5, minute: 35), duration: TimeInterval(hour: 7, minute: 35), saturation: 68.59),
            .init(name: "25", startTime: TimeInterval(hour: 14, minute: 30), duration: TimeInterval(hour: 7, minute: 35), saturation: 68.59),
            .init(name: "SP1", startTime: TimeInterval(hour: 5, minute: 15), duration: TimeInterval(hour: 7, minute: 43), saturation: 68.59),
            .init(name: "SP2", startTime: TimeInterval(hour: 14, minute: 15), duration: TimeInterval(hour: 7, minute: 43), saturation: 68.59),
        ])
    ]
    
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
    
    func standardMinutesFor(date: Date) -> Int {
        let shiftGroups = shiftsGroupsValidsTo(date)
        
        for shiftGroup in shiftGroups {
            for _ in shiftGroup.shifts {
                guard let standarShift = shiftGroup.shifts.first(where: { $0.name == "STDR" }) else { return 0 }
                return standarShift.duration.inMinutes
            }
        }
        
        return 0
    }
}
