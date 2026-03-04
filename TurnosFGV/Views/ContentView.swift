//
//  ContentView.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 21/3/24.
//

import SwiftUI

enum Tab: String {
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
    @AppStorage("selectedTab") private var selectedTab: Tab = .calendar

    var body: some View {
        TabView(selection: $selectedTab) {
            CalendarScreen()
                .setUpTab(.calendar)

            SummaryView()
                .setUpTab(.summary)

            ChartView()
                .setUpTab(.chart)

            SettingsView()
                .setUpTab(.settings)
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

extension View {
    func setUpTab(_ tab: Tab) -> some View {
        self
            .tag(tab)
            .tabItem {
                Label(tab.rawValue, systemImage: tab.icon)
            }
    }
}
