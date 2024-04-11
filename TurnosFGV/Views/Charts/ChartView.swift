//
//  ChartView.swift
//  RegistroTurnos2
//
//  Created by Jose Antonio Mendoza on 3/3/24.
//
import Charts
import SwiftData
import SwiftUI

struct ChartData: Identifiable, Equatable {
    let id: UUID = .init()
    let date: Date
    let workedHours: Double
    
    var isAnimated: Bool = false
}

struct ChartView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedDate: Date
    @State private var data: [ChartData] = []
    @State private var barSelection: Date?
    @State private var isAnimated: Bool = false

    var body: some View {
        NavigationStack {
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
                        
                        Text("Total horas \(selectedDate.toString(format: .custom("yyyy"))!)")
                            .font(.callout)
                            .fontWeight(.light)
                    }
                    .foregroundStyle(.appWhite)
                    .padding(.bottom, 20)
                    
                    Chart {
                        ForEach(data) { dataPoint in
                            BarMark(
                                x: .value("Mes", dataPoint.date, unit: .month),
                                y: .value("Días trabajados", dataPoint.isAnimated ? dataPoint.workedHours : 0)
                            )
                            .cornerRadius(6)
                            .foregroundStyle(.appWhite.gradient)
                            .opacity(dataPoint.isAnimated ? 1 : 0)
                        }

                        if let barSelection {
                            RuleMark(x: .value("Mes", barSelection, unit: .month))
                                .foregroundStyle(.appBackground.opacity(0.35))
                                .zIndex(-10)
                                .offset(yStart: -10)
                                .annotation(position: .top, spacing: 0, overflowResolution: .init(x: .fit, y: .disabled)) {
                                    let workedHours = workedHoursForMonth(barSelection)
                                    ChartPopOverView(workedHours, barSelection)
                                }
                        }
                    }
                    .chartYScale(domain: 0...(data.map(\.workedHours).max() ?? 150.0))
                    .chartXSelection(value: $barSelection)
                    .chartXAxis {
                          AxisMarks(values: .stride(by: .month, count: 1)) { value in
                              if let date = value.as(Date.self) {
                                  AxisValueLabel(date.toString(format: .custom("MMMMM"))!, centered: true)
                              }
                          }
                        }
//                    .chartScrollableAxes(.horizontal)
                    .chartLegend(position: .bottom, alignment: .leading, spacing: 25)
                }
                .frame(height: 300)
                .padding(.vertical)
                .padding(.horizontal, 5)
                .background(.appWhite.opacity(0.1).shadow(.inner(color: .white, radius: 9)), in: .rect(cornerRadius: 10))
                
                Spacer(minLength: 0)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.appBackground)
            .scrollContentBackground(.hidden)
            .navigationTitle("Resumen")
            .task {
                createChartData()
                animateChart()
            }
        }
    }
}

#Preview {
    ChartView(selectedDate: .constant(.now))
        .modelContainer(WorkDay.preview)
}

extension ChartView {
    private var totalWorkedHours: Double {
        data.reduce(0) { $0 + $1.workedHours }
    }
    
    private func createChartData() {
        var data: [ChartData] = []

        for index in 1...12 {
            let firstMonthDay = selectedDate.adjust(month: index)!.adjust(for: .startOfMonth)!.adjust(for: .startOfDay)!
            let lastMonthDay = selectedDate.adjust(month: index)!.adjust(for: .endOfMonth)!.adjust(for: .endOfDay)!

            let descriptor = FetchDescriptor<WorkDay>(predicate: #Predicate {
                return $0.startDate > firstMonthDay && $0.startDate < lastMonthDay
            })

            let workedDays = try? modelContext.fetch(descriptor)
            var workedHours = 0.0
            if let workedDays {
                workedHours = workedDays.reduce(0) { $0 + $1.workedMinutes }.minutesInHours
            }
            let chartData = ChartData(date: firstMonthDay, workedHours: workedHours)

            data.append(chartData)
        }

        self.data = data
    }

    private func workedHoursForMonth(_ month: Date) -> Double {
        if let chartData = data.first(where: { $0.date.component(.month) == month.component(.month) }) {
            return chartData.workedHours
        }
        return 0
    }

    private func animateChart() {
        guard !isAnimated else { return }
        isAnimated = true

        $data.enumerated().forEach { index, element in
            let delay = Double(index) * 0.05
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.smooth) {
                    element.wrappedValue.isAnimated = true
                }
            }
        }
    }

    @ViewBuilder
    private func ChartPopOverView(_ workedHours: Double, _ month: Date) -> some View {
        VStack {
            Text(month.toString(format: .custom("MMMM"))!)
//            Text(month)

            HStack(spacing: 4) {
                Text(String(format: "%.0f", workedHours))
                    .fontWeight(.semibold)

                Text("h.")
                    .textScale(.secondary)
            }
            .font(.caption)
        }
        .padding(4)
        .foregroundStyle(.appWhite)
        .background(.appBackground, in: .rect(cornerRadius: 8))
    }
}
