//
//  PieChartView.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 25/5/24.
//

import Charts
import SwiftUI

struct PieChartView: View {
    @State private var pieSelection: Double? = 0
    
    let chartData: [TypeChartData]
    
    var selectedType: TypeChartData? {
        guard let pieSelection else { return nil }
        var total = 0.0
        return chartData.first {
            total += $0.workedHours
            return pieSelection <= total
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Chart {
                ForEach(chartData) { dataPoint in
                    SectorMark(
                        angle: .value("Tipo", dataPoint.isAnimated ? dataPoint.workedHours : 0),
                        innerRadius: .ratio(0.6),
                        outerRadius: selectedType?.type == dataPoint.type ? .inset(0) : .inset(8),
                        angularInset: 1
                    )
                    .cornerRadius(10)
                    .foregroundStyle(TypeOfShift(rawValue: dataPoint.type)?.color ?? .appWhite)
                    .opacity(dataPoint.isAnimated ? 1 : 0)
                }
            }
            .frame(height: 240)
            .chartAngleSelection(value: $pieSelection.animation(.easeInOut))
            .chartBackground { proxy in
                GeometryReader { geo in
                    if let plotFrame = proxy.plotFrame {
                        let frame = geo[plotFrame]
                        
                        if let selectedType {
                            VStack {
                                HStack(alignment: .firstTextBaseline, spacing: 2) {
                                    Text("\(selectedType.workedHours.formatted(.number.precision(.fractionLength(0))))")
                                        .font(.system(size: 32, weight: .semibold, design: .rounded))
                                        .fontWidth(.compressed)
                                        .contentTransition(.numericText())
                                    Text("h")
                                        .font(.callout)
                                        .fontWeight(.light)
                                }
                                
                                VStack {
                                    Text("Total horas de")
                                    Text(selectedType.type.lowercased())
                                }
                                .font(.caption)
                                .fontWeight(.light)
                                .contentTransition(.identity)
                            }
                            .foregroundStyle(.appWhite)
                            .position(x: frame.midX, y: frame.midY)
                        }
                    }
                }
            }
            
            HStack(spacing: 20) {
                ForEach(TypeOfShift.allCases) { typeOfShift in
                    HStack {
                        Circle()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(typeOfShift.color)
                        Text(typeOfShift.rawValue)
                            .font(.caption)
                    }
                }
            }
            .padding(.top)
        }
        .padding()
        .background(.appWhite.opacity(0.1).shadow(.inner(color: .white, radius: 9)), in: .rect(cornerRadius: 10))
    }
}

#Preview {
    PieChartView(chartData: [])
}
