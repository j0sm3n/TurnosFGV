//
//  BarCharView.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 15/5/24.
//

import Charts
import SwiftUI

struct BarCharView: View {
    @State private var barSelection: Date?
    
    let chartData: [MonthChartData]
    
    var currentYear: Int {
        guard let date = chartData.first?.date else { return 0 }
        return date.year
    }
    
    var monthSelectionWorkedHours: Double {
        guard let barSelection else { return 0 }
        if let data = chartData.first(where: { $0.date.component(.month) == barSelection.component(.month) }) {
            return data.workedHours
        }
        return 0
    }
    
    var body: some View {
        VStack {
            Text("Horas por mes")
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading) {
                VStack {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(totalWorkedHours.formatted(.number.precision(.fractionLength(2))))")
                            .font(.system(size: 32, weight: .semibold, design: .rounded))
                            .fontWidth(.compressed)
                        Text("h")
                            .font(.callout)
                            .fontWeight(.light)
                    }
                    
                    Text("Total horas \(currentYear)")
                        .font(.callout)
                        .fontWeight(.light)
                }
                .foregroundStyle(.appWhite)
                .padding(.bottom, 20)
                
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
                    
                    if let barSelection {
                        RuleMark(x: .value("Mes", barSelection, unit: .month))
                            .foregroundStyle(.appBackground.opacity(0.35))
                            .zIndex(-10)
                            .offset(yStart: -10)
                            .annotation(position: .top, spacing: 0, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                                chartPopOverView
                            }
                    }
                }
                .chartYScale(domain: 0...(chartData.map(\.workedHours).max() ?? 150.0))
                .chartXSelection(value: $barSelection)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .month, count: 1)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel(date.toString(format: .custom("MMMMM"))!, centered: true)
                        }
                    }
                }
                .chartLegend(position: .bottom, alignment: .leading, spacing: 25)
            }
            .frame(height: 300)
            .padding(.vertical)
            .padding(.horizontal, 5)
            .background(.appWhite.opacity(0.1).shadow(.inner(color: .white, radius: 9)), in: .rect(cornerRadius: 10))
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
    
    private var totalWorkedHours: Double {
        chartData.map(\.workedHours).reduce(0, +)
    }
    
    private var chartPopOverView: some View {
        VStack {
            Text(barSelection?.toString(format: .custom("MMMM")) ?? "")
            
            HStack(spacing: 4) {
                Text(String(format: "%.0f", monthSelectionWorkedHours))
                    .fontWeight(.semibold)
                
                Text("h.")
                    .textScale(.secondary)
            }
            .font(.caption)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .foregroundStyle(.appWhite)
        .background(.appBackground, in: .rect(cornerRadius: 8))
    }
}

#Preview {
    BarCharView(chartData: [])
}
