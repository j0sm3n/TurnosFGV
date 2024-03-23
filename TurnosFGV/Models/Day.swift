//
//  Day.swift
//  RegistroTurnos3
//
//  Created by Jose Antonio Mendoza on 22/11/23.
//

import Foundation

struct Day: Identifiable {
    var id: UUID = .init()
    var shortSymbol: String
    var date: Date
    /// Previous/Next Month Excess Dates
    var ignored: Bool = false
}
