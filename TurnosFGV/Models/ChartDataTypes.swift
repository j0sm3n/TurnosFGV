//
//  ChartDataTypes.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 25/5/24.
//

import Foundation

/// Data point representing the total worked hours for a single month, used in the bar chart.
struct MonthChartData: Identifiable {
    let id: UUID = .init()
    /// The month this data point represents (first day of the month).
    let date: Date
    /// Total worked hours for the month.
    let workedHours: Double

    // Animatable property
    var isAnimated: Bool = false
}

/// Data point representing the total worked hours for a single shift type, used in the pie chart.
struct TypeChartData: Identifiable {
    let id: UUID = .init()
    /// Display name of the shift type (e.g. "Mañana", "Intermedio", "Tarde").
    let type: String
    /// Total worked hours for this shift type.
    let workedHours: Double

    // Animatable property
    var isAnimated: Bool = false
}
