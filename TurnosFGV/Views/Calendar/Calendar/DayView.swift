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
    
    private let offset: CGFloat = -4

    var body: some View {
        if day.date.compare(.isSameDay(as: selectedDate)) {
            if #available(iOS 26.0, *) {
                Button {
                    selectedDate = day.date
                } label: {
                    Text(day.shortSymbol)
                        .foregroundStyle(day.ignored ? .secondary : .primary)
                        .fontWeight(day.date.compare(.isSameDay(as: selectedDate)) ? .bold : .regular)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .clipShape(.circle)
                        .overlay(alignment: .bottom) {
                            if let color {
                                Circle()
                                    .offset(y: offset)
                                    .fill(color)
                                    .frame(width: 8, height: 8)
                            }
                        }
                }
                .frame(width: 48, height: 48)
                .glassEffect(.clear)
            } else {
                Button {
                    selectedDate = day.date
                } label: {
                    Text(day.shortSymbol)
                        .foregroundStyle(day.ignored ? .secondary : .primary)
                        .fontWeight(day.date.compare(.isSameDay(as: selectedDate)) ? .bold : .regular)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .overlay(alignment: .bottom) {
                            if let color {
                                Circle()
                                    .offset(y: offset)
                                    .fill(color)
                                    .frame(width: 8, height: 8)
                            }
                        }
                }
                .contentShape(.rect)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .inset(by: 8)
                        .stroke(.appPurple, lineWidth: 1)
                        .offset(y: 9)
                        .frame(width: 60, height: 70)
                }
            }
        } else {
            Button {
                selectedDate = day.date
            } label: {
                Text(day.shortSymbol)
                    .foregroundStyle(day.ignored ? .secondary : .primary)
                    .fontWeight(day.date.compare(.isSameDay(as: selectedDate)) ? .bold : .regular)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .overlay(alignment: .bottom) {
                        if let color {
                            Circle()
                                .offset(y: offset)
                                .fill(color)
                                .frame(width: 8, height: 8)
                        }
                    }
            }
            .contentShape(.rect)
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
