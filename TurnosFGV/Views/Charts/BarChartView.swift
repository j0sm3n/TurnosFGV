//
//  BarChartView.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 25/5/24.
//

import Charts
import SwiftUI
import TipKit
import CloudStorage

struct BarChartView: View {
    @CloudStorage("prevYearHours") var prevYearHours: Double = 0.0
    @State private var barSelection: Date?
    @State private var barChartTip = ChartTip()
    
    let chartData: [MonthChartData]
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                totalHours
                interval
            }
            .foregroundStyle(.appWhite)
            .padding(.bottom, 20)
            .animation(.easeIn, value: barSelection)
            
            Chart {
                ForEach(chartData) { dataPoint in
                    BarMark(
                        x: .value("Mes", dataPoint.date, unit: .month),
                        y: .value("Días trabajados", dataPoint.isAnimated ? dataPoint.workedHours : 0)
                    )
                    .cornerRadius(6)
                    .foregroundStyle(.appWhite.gradient)
                    .opacity(opacityFor(dataPoint: dataPoint))
                }
            }
            .frame(height: 240)
            .chartXSelection(value: $barSelection)
            .chartXAxis {
                AxisMarks(values: .stride(by: .month, count: 1)) {
                    AxisValueLabel(format: .dateTime.month(.narrow), centered: true)
                }
            }
        }
        .padding()
        .background(.appWhite.opacity(0.1).shadow(.inner(color: .white, radius: 9)), in: .rect(cornerRadius: 10))
        .overlay(alignment: .top) {
            if !chartData.isEmpty {
                TipView(barChartTip, arrowEdge: .bottom)
            }
        }
    }
    
    private func opacityFor(dataPoint: MonthChartData) -> Double {
        if dataPoint.isAnimated {
            if let barSelection {
                if barSelection.component(.month) == dataPoint.date.component(.month) {
                    return 1.0
                } else {
                    return 0.3
                }
            } else {
                return 1.0
            }
        }
        return 0.0
    }
    
    private var currentYear: Int {
        guard let date = chartData.first?.date else { return 0 }
        return date.year
    }
    
    private var monthSelectionWorkedHours: String {
        guard let barSelection else { return "" }
        if let data = chartData.first(where: { $0.date.component(.month) == barSelection.component(.month) }) {
            return data.workedHours.formatted(.number.precision(.fractionLength(0)))
        }
        return ""
    }
    
    private var totalWorkedHours: String {
        (chartData.map(\.workedHours).reduce(0, +) + prevYearHours).formatted(.number.precision(.fractionLength(0)))
    }
    
    private var totalHours: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(barSelection != nil ? monthSelectionWorkedHours : totalWorkedHours)
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .fontWidth(.compressed)
                .contentTransition(.numericText())
            Text("h")
                .font(.callout)
                .fontWeight(.light)
        }
    }
    
    private var interval: some View {
        Text((barSelection != nil ? barSelection?.formatted(.dateTime.month(.wide)) : "Total horas \(currentYear)")!)
            .font(.callout)
            .fontWeight(.light)
            .contentTransition(.interpolate)
    }
}

#Preview {
    BarChartView(chartData: [])
}
