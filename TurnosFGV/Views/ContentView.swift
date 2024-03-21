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
    
    var icon: String {
        switch self {
            case .calendar: "calendar"
            case .summary: "doc.plaintext"
            case .chart: "chart.bar.xaxis"
        }
    }
}

struct ContentView: View {
    @State private var currentDate: Date = .now
//    @State private var currentMonth: Date = .currentMonth
    @State private var selectedTab: Tab = .calendar
    
    var body: some View {
        TabView(selection: $selectedTab) {
//            CalendarScreen(selectedDate: $currentDate, selectedMonth: $currentMonth)
            Text("Calendar")
                .setUpTab(.calendar)
            
//            SummaryView(selectedDate: $currentDate, selectedMonth: $currentMonth)
            Text("Summary")
                .setUpTab(.summary)
            
//            ChartView()
            Text("Charts")
                .setUpTab(.chart)
        }
    }
}

#Preview {
    ContentView()
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
