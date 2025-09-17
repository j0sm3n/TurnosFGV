//
//  CalendarView.swift
//  RegistroTurnos2
//
//  Created by Jose Antonio Mendoza on 13/3/24.
//

import SwiftData
import SwiftUI
import DateHelper

struct CalendarView: View {
    @Binding var selectedDate: Date
    @Binding var selectedMonth: Date
    @State private var monthDays: [Day] = []
    @Query private var workDays: [WorkDay]
    
    init(selectedDate: Binding<Date>, selectedMonth: Binding<Date>) {
        self._selectedDate = selectedDate
        self._selectedMonth = selectedMonth
        self._workDays = Query(filter: WorkDay.monthPredicate(month: selectedDate.wrappedValue))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Week day labels
            HStack(spacing: 0) {
                ForEach(Date.weekdaySymbols, id: \.self) { day in
                    Text(day.prefix(3))
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: 18, alignment: .bottom)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(spacing: 0), count: 7), spacing: 0) {
                ForEach(monthDays) { day in
                    DayView(day: day, color: colorOfWorkedDay(day.date), selectedDate: $selectedDate)
                }
            }
            .frame(height: 304, alignment: .top)
            .contentShape(.rect)
            .clipped()
            .redacted(reason: monthDays.isEmpty ? .placeholder : [])
        }
        .task(id: selectedMonth) {
            monthDays = extractDates(selectedMonth)
        }
    }
}

#if DEBUG
#Preview {
    VStack {
        CalendarView(selectedDate: .constant(.now), selectedMonth: .constant(.currentMonth))
            .modelContainer(WorkDay.preview)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .background(.appBackground)
}
#endif

extension CalendarView {
    private func colorOfWorkedDay(_ date: Date) -> Color? {
        workDays.first(where: { $0.startDate.compare(.isSameDay(as: date)) })?.color
    }
}
