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
            .frame(height: 24, alignment: .top)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(spacing: 4), count: 7), spacing: 4) {
                ForEach(monthDays) { day in
                    DayView(day: day)
                        .containerRelativeFrame(.vertical, count: 7, span: 1, spacing: 0)
                }
            }
            .redacted(reason: monthDays.isEmpty ? .placeholder : [])
        }
        .padding(.horizontal, 6)
        .frame(maxHeight: .infinity)
        .task(id: selectedMonth) {
            monthDays = extractDates(selectedMonth)
        }
    }
}

#Preview {
    CalendarView(selectedDate: .constant(.now), selectedMonth: .constant(.currentMonth))
        .modelContainer(for: WorkDay.self, inMemory: true)
}

extension CalendarView {
    private func workedDayOn(_ date: Date) -> WorkDay? {
        workDays.first(where: { $0.startDate.compare(.isSameDay(as: date)) })
    }
    
    private func DayView(day: Day) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(.appBlue.opacity(0.1).shadow(day.date.compare(.isSameDay(as: selectedDate))
                                                   ? .inner(color: .white, radius: 3)
                                                   : .drop(color: .white, radius: 1))
                )
            
            VStack(spacing: 20) {
                Text(day.shortSymbol)
                    .foregroundStyle(day.ignored ? .secondary : .primary)
                    .fontWeight(day.date.compare(.isSameDay(as: .now)) ? .bold : .regular)
                    .vSpacing(.top)
                    .hSpacing(.leading)
                    .padding(.top, 5)
                    .padding(.leading, 5)
                    .overlay(alignment: .center) {
                        if let workedDay = workedDayOn(day.date) {
                            Text(workedDay.shift)
                                .font(.system(size: workedDay.shift.count > 2 ? 18 : 32, weight: .semibold, design: .rounded))
                                .fontWidth(.compressed)
                                .foregroundStyle(workedDay.color)
                                .vSpacing(.center)
                        }
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(.rect)
            .onTapGesture {
                selectedDate = day.date
            }
        }
    }
}
