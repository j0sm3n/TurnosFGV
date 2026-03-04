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
    @Environment(DateSelectionViewModel.self) var dateVM
    @State private var viewModel = ChartViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    BarChartView(chartData: viewModel.barChartData)
                    PieChartView(chartData: viewModel.pieChartData)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.appBackground)
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .navigationTitle("Resumen \(dateVM.currentDate.year)")
            .onAppear {
                viewModel.loadData(for: dateVM.currentDate, from: modelContext)
                viewModel.animateChart()
            }
            .onDisappear {
                viewModel.resetAnimation()
            }
        }
    }
}

#Preview {
    ChartView()
#if DEBUG
        .modelContainer(WorkDay.preview)
        .environment(DateSelectionViewModel())
#endif
}
