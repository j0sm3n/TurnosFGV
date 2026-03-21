//
//  Day.swift
//  RegistroTurnos3
//
//  Created by Jose Antonio Mendoza on 22/11/23.
//

import Foundation

/// Represents a single cell in the calendar month grid.
struct Day: Identifiable {
    var id: UUID = .init()
    /// Two-digit day number string used as the cell label (e.g. "01", "15").
    var shortSymbol: String
    /// The calendar date this cell corresponds to.
    var date: Date
    /// When `true`, this cell belongs to the previous or next month and is shown only as grid padding.
    var ignored: Bool = false
}
