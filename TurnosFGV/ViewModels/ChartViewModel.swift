//
//  ChartViewModel.swift
//  TurnosFGV
//

import Algorithms
import Foundation
import SwiftUI

@MainActor
@Observable
final class ChartViewModel {
    private(set) var barChartData: [MonthChartData] = []
    private(set) var pieChartData: [TypeChartData] = []
    private(set) var isAnimated: Bool = false
    private(set) var loadState: Loadable<Void> = .idle
    private var animationTask: Task<Void, Never>?

    func loadData(for date: Date, using repository: any WorkDayRepository) {
        loadState = .loading
        do {
            let allDays = try repository.fetchAll()
            let daysInYear = WorkDay.filtered(allDays, byYear: date)
            barChartData = createBarChartData(from: daysInYear)
            pieChartData = createPieChartData(from: daysInYear)
            loadState = .loaded(())
        } catch {
            loadState = .failed(error.localizedDescription)
        }
    }

    func animateChart() {
        guard !isAnimated else { return }
        isAnimated = true
        animationTask?.cancel()

        animationTask = Task { [weak self] in
            guard let self else { return }
            for index in self.barChartData.indices {
                guard !Task.isCancelled else { return }
                withAnimation(.smooth) { self.barChartData[index].isAnimated = true }
                try? await Task.sleep(for: .milliseconds(50))
            }
            for index in self.pieChartData.indices {
                guard !Task.isCancelled else { return }
                withAnimation(.smooth) { self.pieChartData[index].isAnimated = true }
                try? await Task.sleep(for: .milliseconds(50))
            }
        }
    }

    func resetAnimation() {
        animationTask?.cancel()
        animationTask = nil
        barChartData.indices.forEach { barChartData[$0].isAnimated = false }
        isAnimated = false
    }

    // MARK: - Private helpers

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
