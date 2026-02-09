//
//  Shift+Extensions.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 22/3/24.
//

import SwiftUI

extension Shift {
    var endTime: TimeInterval {
        startTime + duration
    }
    
    var typeOfShift: TypeOfShift {
        .determine(startTime: startTime, endTime: endTime)
    }
    
    var color: Color {
        typeOfShift.color
    }
}

extension Shift: Equatable, Comparable, Hashable {
    static func == (lhs: Shift, rhs: Shift) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func < (lhs: Shift, rhs: Shift) -> Bool {
        lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
    }
}
