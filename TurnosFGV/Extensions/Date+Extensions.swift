//
//  Date+Extensions.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 21/3/24.
//

import Foundation

extension Date {
    init?(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0) {
        guard let date = DateComponents(calendar: .current, year: year, month: month, day: day, hour: hour, minute: minute).date else {
            return nil
        }
        self = date
    }
}
