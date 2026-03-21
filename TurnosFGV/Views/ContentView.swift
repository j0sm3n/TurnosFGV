//
//  ContentView.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 21/3/24.
//

import SwiftUI

struct ContentView: View {
    @State private var dateVM = DateSelectionViewModel()

    var body: some View {
        TabView {
            Tab("Calendario", systemImage: "calendar") {
                CalendarScreen()
            }
            Tab("Nómina", systemImage: "doc.plaintext") {
                SummaryView()
            }
            Tab("Resumen", systemImage: "chart.bar.xaxis") {
                ChartView()
            }
            Tab("Ajustes", systemImage: "gearshape") {
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
