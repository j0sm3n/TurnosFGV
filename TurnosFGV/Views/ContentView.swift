//
//  ContentView.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 21/3/24.
//

import SwiftUI

enum AppTab: String {
    case calendar = "Calendario"
    case summary = "Nómina"
    case chart = "Resumen"
    case settings = "Ajustes"

    var icon: String {
        switch self {
            case .calendar: "calendar"
            case .summary: "doc.plaintext"
            case .chart: "chart.bar.xaxis"
            case .settings: "gearshape"
        }
    }
}

struct ContentView: View {
    @State private var dateVM = DateSelectionViewModel()
    @AppStorage("selectedTab") private var selectedTab: AppTab = .calendar

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(AppTab.calendar.rawValue, systemImage: AppTab.calendar.icon, value: AppTab.calendar) {
                CalendarScreen()
            }
            Tab(AppTab.summary.rawValue, systemImage: AppTab.summary.icon, value: AppTab.summary) {
                SummaryView()
            }
            Tab(AppTab.chart.rawValue, systemImage: AppTab.chart.icon, value: AppTab.chart) {
                ChartView()
            }
            Tab(AppTab.settings.rawValue, systemImage: AppTab.settings.icon, value: AppTab.settings) {
                SettingsView()
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .environment(dateVM)
    }
}

#Preview {
    ContentView()
    #if DEBUG
        .modelContainer(WorkDay.preview)
    #endif
}
