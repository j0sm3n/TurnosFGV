//
//  Int+Extensions.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 27/3/24.
//

import Foundation

extension Int {
    var minutesInHours: Double {
        (Double(self) / 60).roundToDecimal(2)
    }
}
