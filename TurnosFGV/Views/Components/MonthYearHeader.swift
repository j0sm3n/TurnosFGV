//
//  MonthYearHeader.swift
//  RegistroTurnos2
//
//  Created by Jose Antonio Mendoza on 3/3/24.
//

import SwiftUI
import DateHelper

struct MonthYearHeader: View {
    @Binding var selectedDate: Date
    @Binding var selectedMonth: Date

    var body: some View {
        HStack {
            HStack {
                Text(selectedMonth.toString(format: .custom("MMMM"))!)
                    .foregroundStyle(.appWhite)
                Text(selectedMonth.toString(format: .isoYear)!)
                    .foregroundStyle(.appPurple)
            }
            .font(.title)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 15) {
                Button {
                    // Update to Previous Month
                    monthUpdate(false)
                } label: {
                    Image(systemName: "chevron.left")
                        .contentShape(.rect)
                }
                
                Button {
                    selectedDate = Date.now
                    withAnimation {
                        selectedMonth = Date.now.adjust(for: .startOfMonth)!
                    }
                } label: {
                    Image(systemName: "circle.fill")
                        .contentShape(.rect)
                        .font(.callout)
                }
                
                Button {
                    // Update to Next Month
                    monthUpdate(true)
                } label: {
                    Image(systemName: "chevron.right")
                        .contentShape(.rect)
                }
            }
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundStyle(.appPurple)
        }
        .padding(.horizontal)
    }
    
    private func monthUpdate(_ increment: Bool = true) {
        let calendar = Calendar.current
        guard let month = calendar.date(byAdding: .month, value: increment ? 1 : -1, to: selectedMonth) else { return }
        guard let date = calendar.date(byAdding: .month, value: increment ? 1 : -1, to: selectedDate) else { return }
        withAnimation {
            selectedMonth = month
        }
        selectedDate = date
    }
}

#Preview {
    MonthYearHeader(selectedDate: .constant(.now), selectedMonth: .constant(.now.adjust(for: .startOfMonth)!))
}
