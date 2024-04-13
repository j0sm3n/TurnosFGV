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
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedDate: Date
    @Binding var selectedMonth: Date
    @State private var monthDays: [Day] = []
    @State private var workDays: [WorkDay] = []
    
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
                        .overlay {
                            if day.date.compare(.isSameDay(as: selectedDate)) {
                                RoundedRectangle(cornerRadius: 20)
                                    .inset(by: 8)
                                    .stroke(.appPurple, lineWidth: 1)
                                    .offset(y: 9)
                                    .frame(width: 60, height: 70)
                            }
                        }
                }
            }
            .frame(height: 304, alignment: .top)
            .contentShape(.rect)
            .clipped()
            .redacted(reason: monthDays.isEmpty ? .placeholder : [])
        }
        .task(id: selectedMonth) {
            fetchData()
        }
    }
}

#Preview {
    CalendarView(selectedDate: .constant(.now), selectedMonth: .constant(.currentMonth))
        .modelContainer(for: WorkDay.self, inMemory: true)
}

extension CalendarView {
    private func colorOfWorkedDay(_ date: Date) -> Color? {
        workDays.first(where: { $0.startDate.compare(.isSameDay(as: date)) })?.color
    }
    
    private func fetchData() {
        monthDays = extractDates(selectedMonth)
        getMonthWorkDays()
    }
    
    private func getMonthWorkDays() {
        if let workDays = try? modelContext.fetch(WorkDay.monthDescriptor(month: selectedMonth)) {
            self.workDays = workDays
        }
    }
}
