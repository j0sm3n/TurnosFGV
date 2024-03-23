//
//  CalendarScreen.swift
//  RegistroTurnos2
//
//  Created by Jose Antonio Mendoza on 11/2/24.
//

import SwiftData
import SwiftUI

struct CalendarScreen: View {
    @Binding var selectedDate: Date
    @Binding var selectedMonth: Date
    
    var body: some View {
        NavigationStack {
            VStack {
                MonthYearHeader(selectedDate: $selectedDate, selectedMonth: $selectedMonth)
                CalendarView(selectedDate: $selectedDate, selectedMonth: $selectedMonth)
                RecordsView(selectedDate: $selectedDate, selectedMonth: $selectedMonth)
            }
            .background(.appBackground)
        }
    }
}

#Preview {
    ContentView()
}
