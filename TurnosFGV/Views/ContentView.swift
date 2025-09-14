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
    @State private var currentDate: Date = .now
    @State private var currentMonth: Date = .currentMonth
    @AppStorage("selectedTab") private var selectedTab: Tab = .calendar
    
    var body: some View {
        if #available(iOS 26.0, *) {
            TabView(selection: $selectedTab) {
                CalendarScreen(selectedDate: $currentDate, selectedMonth: $currentMonth)
                    .setUpTab(.calendar)
                
                SummaryView(selectedDate: $currentDate, selectedMonth: $currentMonth)
                    .setUpTab(.summary)
                
                ChartView(selectedDate: $currentDate)
                    .setUpTab(.chart)
                
                SettingsView()
                    .setUpTab(.settings)
            }
            .tabBarMinimizeBehavior(.onScrollDown)
        } else {
            TabView(selection: $selectedTab) {
                CalendarScreen(selectedDate: $currentDate, selectedMonth: $currentMonth)
                    .setUpTab(.calendar)
                
                SummaryView(selectedDate: $currentDate, selectedMonth: $currentMonth)
                    .setUpTab(.summary)
                
                ChartView(selectedDate: $currentDate)
                    .setUpTab(.chart)
                
                SettingsView()
                    .setUpTab(.settings)
            }
        }
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
