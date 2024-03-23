//
//  ShiftsDataModel.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 21/3/24.
//

import SwiftUI
import DateHelper

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

enum Role: String, Identifiable, CaseIterable {
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

enum Location: String, Identifiable, CaseIterable {
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
    let shiftGroups = {
        // Maquinista Benidorm
        let maquinistasB = ShiftGroup(validFrom: .init(fromString: "2023-07-14", format: .isoDate)!, role: .maquinista, location: .benidorm, shifts: [
            .init(name: "1", startTime: TimeInterval(hour: 5, minute: 27), duration: TimeInterval(hour: 8, minute: 9), saturation: 71.2),
            .init(name: "2", startTime: TimeInterval(hour: 6, minute: 27), duration: TimeInterval(hour: 8, minute: 9), saturation: 71.2),
            .init(name: "3", startTime: TimeInterval(hour: 11, minute: 52), duration: TimeInterval(hour: 7, minute: 44), saturation: 55.3),
            .init(name: "4", startTime: TimeInterval(hour: 13, minute: 52), duration: TimeInterval(hour: 8, minute: 59), saturation: 65.18),
            .init(name: "5", startTime: TimeInterval(hour: 14, minute: 52), duration: TimeInterval(hour: 8, minute: 23), saturation: 59.69),
            .init(name: "8", startTime: TimeInterval(hour: 5, minute: 45), duration: TimeInterval(hour: 7, minute: 15), saturation: 62.82),
            .init(name: "9", startTime: TimeInterval(hour: 13, minute: 45), duration: TimeInterval(hour: 7, minute: 15), saturation: 62.82),
            .init(name: "STDR", startTime: TimeInterval(hour: 7), duration: TimeInterval(hour: 7, minute: 49)),
            .init(name: "A1", startTime: TimeInterval(hour: 23, minute: 30), duration: TimeInterval(hour: 6), saturation: 57.14)
        ])
        
        // Maquinista Denia
        let maquinistasD = ShiftGroup(validFrom: .init(fromString: "2023-07-14", format: .isoDate)!, role: .maquinista, location: .denia, shifts: [
            .init(name: "21", startTime: TimeInterval(hour: 5, minute: 5), duration: TimeInterval(hour: 7, minute: 52), saturation: 59.25),
            .init(name: "22", startTime: TimeInterval(hour: 5, minute: 20), duration: TimeInterval(hour: 8, minute: 37), saturation: 64.41),
            .init(name: "23", startTime: TimeInterval(hour: 9, minute: 35), duration: TimeInterval(hour: 7, minute: 22), saturation: 66.26),
            .init(name: "24", startTime: TimeInterval(hour: 14, minute: 35), duration: TimeInterval(hour: 8, minute: 22), saturation: 51.48),
            .init(name: "25", startTime: TimeInterval(hour: 16, minute: 35), duration: TimeInterval(hour: 6, minute: 36), saturation: 58.20),
            .init(name: "26", startTime: TimeInterval(hour: 5, minute: 15), duration: TimeInterval(hour: 7, minute: 15), saturation: 60.72),
            .init(name: "27", startTime: TimeInterval(hour: 14, minute: 45), duration: TimeInterval(hour: 7), saturation: 60.72)
        ])
        
        return [maquinistasB, maquinistasD]
    }()
    
    func shiftsGroupsValidsTo(_ date: Date) -> [ShiftGroup] {
        guard let role = UserDefaults.standard.string(forKey: "role") else { return [] }
        var actualShiftGroups: [ShiftGroup] = []
        
        for location in Location.allCases {
            if let shiftGroup = shiftGroups.first(where: { $0.validFrom <= date && $0.role.rawValue == role && $0.location == location }) {
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
}
