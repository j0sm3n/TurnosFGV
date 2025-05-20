//
//  Double+Extensions.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 14/4/24.
//

import Foundation

extension Double {
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = Double.pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}
