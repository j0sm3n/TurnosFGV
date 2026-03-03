//
//  ChartView.swift
//  RegistroTurnos2
//
//  Created by Jose Antonio Mendoza on 3/3/24.
//
import Algorithms
import SwiftData
import SwiftUI

struct ChartView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedDate: Date
    
    @State private var barChartData: [MonthChartData] = []
    @State private var pieChartData: [TypeChartData] = []
    
    @State private var isAnimated: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    BarChartView(chartData: barChartData)
                    PieChartView(chartData: pieChartData)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.appBackground)
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .navigationTitle("Resumen \(selectedDate.year)")
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
    private func createData() {
        guard let days = workedDaysInYear() else { return }
        barChartData = createBarChartData(from: days)
        pieChartData = createPieChartData(from: days)
    }
    
    private func workedDaysInYear() -> [WorkDay]? {
        let startOfYear = selectedDate.startOfYear.startOfDay
        let endOfYear = selectedDate.endOfYear.endOfDay
        
        let descriptor = FetchDescriptor<WorkDay>(
            predicate: #Predicate { ($0.startDate > startOfYear) && ($0.startDate < endOfYear) },
            sortBy: [SortDescriptor(\.startDate)]
        )
        
        guard let workedDaysInYear = try? modelContext.fetch(descriptor) else { return nil }
        return workedDaysInYear
    }
    
    private func createBarChartData(from workedDaysInYear: [WorkDay]) -> [MonthChartData] {
        let workedDaysArray = workedDaysInYear.chunked { $0.startDate.component(.month) == $1.startDate.component(.month) }
        var monthChartData: [MonthChartData] = []
        
        for array in workedDaysArray {
            guard let firstValue = array.first else { continue }
            let total = array.map(\.workedTimeInHours).reduce(0, +)
            monthChartData.append(.init(date: firstValue.startDate, workedHours: total))
        }
        
        return monthChartData
    }
    
    private func createPieChartData(from workedDaysInYear: [WorkDay]) -> [TypeChartData] {
        var typeChartData: [TypeChartData] = []
        
        for typeOfShift in TypeOfShift.allCases {
            let workedHours = workedDaysInYear
                .filter { $0.typeOfShift == typeOfShift }.map(\.workedTimeInHours).reduce(0, +)
            let chartData = TypeChartData(type: typeOfShift.rawValue, workedHours: workedHours)
            typeChartData.append(chartData)
        }
        
        return typeChartData
    }
    
    private func animateChart() {
        guard !isAnimated else { return }
        isAnimated = true

        for (index, _) in barChartData.enumerated() {
            let delay = Double(index) * 0.05
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(delay))
                withAnimation(.smooth) {
                    barChartData[index].isAnimated = true
                }
            }
        }

        for (index, _) in pieChartData.enumerated() {
            let delay = Double(index) * 0.05
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(delay))
                withAnimation(.smooth) {
                    pieChartData[index].isAnimated = true
                }
            }
        }
    }
    
    private func resetChartAnimation() {
        barChartData.indices.forEach { barChartData[$0].isAnimated = false }
        isAnimated = false
    }
}
