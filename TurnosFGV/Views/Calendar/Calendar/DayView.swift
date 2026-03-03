//
//  DayView.swift
//  RegistroTurnos2
//
//  Created by Jose Antonio Mendoza on 13/3/24.
//

import SwiftUI

struct DayView: View {
    let day: Day
    let color: Color?
    @Binding var selectedDate: Date
    
    private let dotOffset: CGFloat = -4

    private var isSelected: Bool {
        day.date.isSameDay(as: selectedDate)
    }

    var body: some View {
        if isSelected {
            dayButton
                .frame(width: 48, height: 48)
                .glassEffect(.clear)
        } else {
            dayButton
                .contentShape(.rect)
        }
    }

    private var dayButton: some View {
        Button {
            selectedDate = day.date
        } label: {
            Text(day.shortSymbol)
                .foregroundStyle(day.ignored ? .secondary : .primary)
                .fontWeight(isSelected ? .bold : .regular)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .overlay(alignment: .bottom) {
                    if let color {
                        Circle()
                            .offset(y: dotOffset)
                            .fill(color)
                            .frame(width: 8, height: 8)
                    }
                }
        }
    }
}

#Preview {
    VStack {
        DayView(day: .init(shortSymbol: "18", date: .now), color: .appBlue, selectedDate: .constant(.now))
        DayView(day: .init(shortSymbol: "19", date: .now), color: .appYellow, selectedDate: .constant(.distantPast))
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    .background(.appBackground)
}
