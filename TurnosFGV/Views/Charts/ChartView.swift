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
    var date: Date?
    let workedHours: Double
    var type: String?
    
    // Animatable propertie
    var isAnimated: Bool = false
}

struct ChartView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedDate: Date
    @State private var barChartData: [ChartData] = []
    @State private var pieChartData: [ChartData] = []
    @State private var barSelection: Date?
    @State private var pieSelection: Double?
    @State private var selectedType: ChartData?
    @State private var isAnimated: Bool = false
    
    let typeOfShifts: [TypeOfShift] = TypeOfShift.allCases
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    AnnualHoursPerMonth
                    AnnualHoursPerType
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.appBackground)
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .navigationTitle("Resumen")
            .onAppear {
                createData()
                animateChart()
            }
            .onDisappear(perform: resetChartAnimation)
        }
    }
}

#Preview {
    ChartView(selectedDate: .constant(.now))
    #if DEBUG
        .modelContainer(WorkDay.preview)
    #endif
}

extension ChartView {
    // MARK: - Extracted Views
    @ViewBuilder
    private var AnnualHoursPerMonth: some View {
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
                    ForEach(barChartData) { dataPoint in
                        BarMark(
                            x: .value("Mes", dataPoint.date ?? .now, unit: .month),
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
                .chartYScale(domain: 0...(barChartData.map(\.workedHours).max() ?? 150.0))
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
        }
    }
    
    @ViewBuilder
    private var AnnualHoursPerType: some View {
        VStack {
            Text("Horas por tipo")
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack {
                Chart {
                    ForEach(pieChartData) { dataPoint in
                        SectorMark(
                            angle: .value("Tipo", dataPoint.isAnimated ? dataPoint.workedHours : 0),
                            innerRadius: .ratio(0.6),
                            outerRadius: selectedType?.type == dataPoint.type ? .inset(0) : .inset(8),
                            angularInset: 1
                        )
                        .cornerRadius(10)
                        .foregroundStyle(TypeOfShift(rawValue: dataPoint.type!)?.color ?? .appWhite)
                        .opacity(dataPoint.isAnimated ? 1 : 0)
                    }
                }
                .chartAngleSelection(value: $pieSelection)
                .chartBackground { _ in
                    if let selectedType {
                        VStack {
                            HStack(alignment: .firstTextBaseline, spacing: 2) {
                                Text("\(selectedType.workedHours.formatted(.number.precision(.fractionLength(2))))")
                                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                                    .fontWidth(.compressed)
                                Text("h")
                                    .font(.callout)
                                    .fontWeight(.light)
                            }
                            
                            VStack {
                                Text("Total horas de")
                                Text(selectedType.type!.lowercased())
                            }
                            .font(.caption)
                            .fontWeight(.light)
                        }
                        .foregroundStyle(.appWhite)
                        .padding(.top)
                    }
                }
                
                HStack(spacing: 20) {
                    ForEach(typeOfShifts) { typeOfShift in
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
            .frame(height: 300)
            .padding(.vertical)
            .padding(.horizontal, 5)
            .background(.appWhite.opacity(0.1).shadow(.inner(color: .white, radius: 9)), in: .rect(cornerRadius: 10))
            .onChange(of: pieSelection) { oldValue, newValue in
                if let newValue {
                    withAnimation {
                        getSelectedType(value: newValue)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func ChartPopOverView(_ workedHours: Double, _ month: Date) -> some View {
        VStack {
            Text(month.toString(format: .custom("MMMM"))!)
            
            HStack(spacing: 4) {
                Text(String(format: "%.0f", workedHours))
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
    
    // MARK: - Computed properties and functions
    private var totalWorkedHours: Double {
        barChartData.reduce(0) { $0 + $1.workedHours }
    }
    
    private func createData() {
        createBarChartData()
        createPieChartData()
    }
    
    private func createBarChartData() {
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
                workedHours = workedDays.reduce(0) { $0 + $1.workedTimeInHours }
            }
            let chartData = ChartData(date: firstMonthDay, workedHours: workedHours)
            
            data.append(chartData)
        }
        
        barChartData = data
    }
    
    private func createPieChartData() {
        var data: [ChartData] = []
        
        let startOfYear = selectedDate.adjust(for: .startOfYear)!.adjust(for: .startOfDay)!
        let endOfYear = selectedDate.adjust(for: .endOfYear)!.adjust(for: .endOfDay)!
        
        let descriptor = FetchDescriptor<WorkDay>(predicate: #Predicate {
            return ($0.startDate > startOfYear) && ($0.startDate < endOfYear)
        })
        
        guard let workedDaysInYear = try? modelContext.fetch(descriptor) else { return }
        
        for typeOfShift in TypeOfShift.allCases {
            let workedHours = workedDaysInYear
                .filter { $0.typeOfShift == typeOfShift }
                .reduce(0) { $0 + $1.workedTimeInHours }
            let chartData = ChartData(workedHours: workedHours, type: typeOfShift.rawValue)
            data.append(chartData)        }
        
        pieChartData = data
    }
    
    private func workedHoursForMonth(_ month: Date) -> Double {
        if let chartData = barChartData.first(where: { $0.date?.component(.month) == month.component(.month) }) {
            return chartData.workedHours
        }
        return 0
    }
    
    private func getSelectedType(value: Double) {
        var cumulativeTotal = 0.0
        let _ = pieChartData.first { dataPoint in
            cumulativeTotal += dataPoint.workedHours
            if value <= cumulativeTotal {
                selectedType = dataPoint
                return true
            }
            return false
        }
    }
    
    private func animateChart() {
        guard !isAnimated else { return }
        isAnimated = true
        
        $barChartData.enumerated().forEach { index, element in
            let delay = Double(index) * 0.05
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.smooth) {
                    element.wrappedValue.isAnimated.toggle()
                }
            }
        }
        
        $pieChartData.enumerated().forEach { index, element in
            let delay = Double(index) * 0.05
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.smooth) {
                    element.wrappedValue.isAnimated.toggle()
                }
            }
        }
    }
    
    private func resetChartAnimation() {
        $barChartData.forEach {
            $0.wrappedValue.isAnimated = false
        }
        
        isAnimated = false
    }
}
