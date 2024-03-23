//
//  DayView.swift
//  RegistroTurnos2
//
//  Created by Jose Antonio Mendoza on 13/3/24.
//

import SwiftUI
import DateHelper

struct DayView: View {
    let day: Day
    let color: Color?
    @Binding var selectedDate: Date

    var body: some View {
        Text(day.shortSymbol)
            .foregroundStyle(day.ignored ? .secondary : .primary)
            .fontWeight(day.date.compare(.isSameDay(as: selectedDate)) ? .bold : .regular)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .overlay(alignment: .bottom) {
                if let color {
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)
                }
            }
            .contentShape(.rect)
            .onTapGesture {
                selectedDate = day.date
            }
    }
}

#Preview {
    DayView(day: .init(shortSymbol: "X", date: .now), color: .pink, selectedDate: .constant(.now))
}
