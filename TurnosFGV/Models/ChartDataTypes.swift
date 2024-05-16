//
//  ChartDataTypes.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 15/5/24.
//

import Foundation

struct MonthChartData: Identifiable {
    let id: UUID = .init()
    let date: Date
    let workedHours: Double
    
    // Animatable propertie
    var isAnimated: Bool = false
}

struct TypeChartData: Identifiable {
    let id: UUID = .init()
    let type: String
    let workedHours: Double
    
    // Animatable propertie
    var isAnimated: Bool = false
}
