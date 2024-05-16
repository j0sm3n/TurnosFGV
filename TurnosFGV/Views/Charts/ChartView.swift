//
//  ChartView.swift
//  RegistroTurnos2
//
//  Created by Jose Antonio Mendoza on 3/3/24.
//

import Algorithms
import Charts
import SwiftData
import SwiftUI

struct ChartView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedDate: Date

    @State private var pieChartData: [TypeChartData] = []
    @State private var barChartData: [MonthChartData] = []

    @State private var isAnimated: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    BarCharView(chartData: barChartData)
                    PieChartView(chartData: pieChartData)
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
    private func createData() {
        barChartData = createBarChartData()
        pieChartData = createPieChartData()
    }
    
    private func workedDaysInYear() -> [WorkDay]? {
        let startOfYear = selectedDate.adjust(for: .startOfYear)!.adjust(for: .startOfDay)!
        let endOfYear = selectedDate.adjust(for: .endOfYear)!.adjust(for: .endOfDay)!
        
        let descriptor = FetchDescriptor<WorkDay>(
            predicate: #Predicate { ($0.startDate > startOfYear) && ($0.startDate < endOfYear) },
            sortBy: [SortDescriptor(\.startDate)]
        )
        
        guard let workedDaysInYear = try? modelContext.fetch(descriptor) else { return nil }
        return workedDaysInYear
    }
    
    private func createBarChartData() -> [MonthChartData] {
        guard let workedDaysInYear = workedDaysInYear() else { return [] }
        let workedDaysArray = workedDaysInYear.chunked { $0.startDate.component(.month) == $1.startDate.component(.month) }
        var monthChartData: [MonthChartData] = []
        
        for array in workedDaysArray {
            guard let firstValue = array.first else { continue }
            let total = array.map(\.workedTimeInHours).reduce(0, +)
            
            monthChartData.append(.init(date: firstValue.startDate, workedHours: total))
        }
        
        return monthChartData
    }
    
    private func createPieChartData() -> [TypeChartData] {
        guard let workedDaysInYear = workedDaysInYear() else { return [] }
        
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
