//
//  ShiftGroup+Extensions.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 23/3/24.
//

import Foundation

extension ShiftGroup: Comparable {
    static func < (lhs: ShiftGroup, rhs: ShiftGroup) -> Bool {
        lhs.validFrom < rhs.validFrom
    }
    
    static func == (lhs: ShiftGroup, rhs: ShiftGroup) -> Bool {
        lhs.id == rhs.id
    }
}
