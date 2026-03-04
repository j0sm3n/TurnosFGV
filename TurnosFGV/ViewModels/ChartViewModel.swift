//
//  ChartViewModel.swift
//  TurnosFGV
//

import Algorithms
import Foundation
import SwiftData
import SwiftUI

@Observable
final class ChartViewModel {
    private(set) var barChartData: [MonthChartData] = []
    private(set) var pieChartData: [TypeChartData] = []
    private(set) var isAnimated: Bool = false
    private var animationTasks: [Task<Void, Never>] = []

    func loadData(for date: Date, from context: ModelContext) {
        guard let days = workedDaysInYear(for: date, from: context) else { return }
        barChartData = createBarChartData(from: days)
        pieChartData = createPieChartData(from: days)
    }

    func animateChart() {
        guard !isAnimated else { return }
        isAnimated = true

        for (index, _) in barChartData.enumerated() {
            let delay = Double(index) * 0.05
            animationTasks.append(Task { @MainActor [weak self] in
                try? await Task.sleep(for: .seconds(delay))
                guard !Task.isCancelled, let self, index < self.barChartData.count else { return }
                withAnimation(.smooth) {
                    self.barChartData[index].isAnimated = true
                }
            })
        }

        for (index, _) in pieChartData.enumerated() {
            let delay = Double(index) * 0.05
            animationTasks.append(Task { @MainActor [weak self] in
                try? await Task.sleep(for: .seconds(delay))
                guard !Task.isCancelled, let self, index < self.pieChartData.count else { return }
                withAnimation(.smooth) {
                    self.pieChartData[index].isAnimated = true
                }
            })
        }
    }

    func resetAnimation() {
        animationTasks.forEach { $0.cancel() }
        animationTasks.removeAll()
        barChartData.indices.forEach { barChartData[$0].isAnimated = false }
        isAnimated = false
    }

    // MARK: - Private helpers

    private func workedDaysInYear(for date: Date, from context: ModelContext) -> [WorkDay]? {
        let startOfYear = date.startOfYear.startOfDay
        let endOfYear = date.endOfYear.endOfDay

        let descriptor = FetchDescriptor<WorkDay>(
            predicate: #Predicate { ($0.startDate > startOfYear) && ($0.startDate < endOfYear) },
            sortBy: [SortDescriptor(\.startDate)]
        )

        return try? context.fetch(descriptor)
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
            typeChartData.append(TypeChartData(type: typeOfShift.rawValue, workedHours: workedHours))
        }

        return typeChartData
    }
}
