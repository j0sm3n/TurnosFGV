//
//  DateSelectionViewModel.swift
//  TurnosFGV
//

import Foundation

@Observable
final class DateSelectionViewModel {
    var currentDate: Date = .now
    var currentMonth: Date = .currentMonth
}
