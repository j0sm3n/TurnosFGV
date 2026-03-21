//
//  CalendarScreen.swift
//  RegistroTurnos2
//
//  Created by Jose Antonio Mendoza on 11/2/24.
//

import SwiftData
import SwiftUI

struct CalendarScreen: View {
    @Environment(DateSelectionViewModel.self) var dateVM

    var body: some View {
        @Bindable var dateVM = dateVM
        NavigationStack {
            VStack {
                MonthYearHeader()
                CalendarView(selectedDate: $dateVM.currentDate, selectedMonth: $dateVM.currentMonth)
                RecordsView(selectedDate: $dateVM.currentDate, selectedMonth: $dateVM.currentMonth)
            }
            .background(.appBackground)
        }
    }
}

#Preview {
    ContentView()
}
