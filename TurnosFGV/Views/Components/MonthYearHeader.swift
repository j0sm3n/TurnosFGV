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
    
    @State private var showMonthYearPicker: Bool = false

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
            .onTapGesture {
                showMonthYearPicker.toggle()
            }
            
            HStack(spacing: 15) {
                decrease(isMonth: true)
                
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
                
                increase(isMonth: true)
            }
            .font(.title3)
            .fontWeight(.bold)
            .foregroundStyle(.appPurple)
        }
        .padding(.horizontal)
        .sheet(isPresented: $showMonthYearPicker) {
            NavigationStack {
                monthYearPicker
            }
            .presentationDetents([.height(240)])
        }
    }
}

#Preview {
    MonthYearHeader(selectedDate: .constant(.now), selectedMonth: .constant(.now.adjust(for: .startOfMonth)!))
}

extension MonthYearHeader {
    private func decrease(isMonth: Bool = false) -> some View {
        Button {
            // Update to Previous Month/Year
            monthYearUpdate(increment: false, isMonth: isMonth)
        } label: {
            Image(systemName: "chevron.left")
                .padding(8)
                .contentShape(.rect)
        }
    }
    
    private func increase(isMonth: Bool = false) -> some View {
        Button {
            // Update to Next Month/Year
            monthYearUpdate(increment: true, isMonth: isMonth)
        } label: {
            Image(systemName: "chevron.right")
                .padding(8)
                .contentShape(.rect)
        }
    }
    
    @ViewBuilder
    private var monthYearPicker: some View {
        let months: [String] = Calendar.current.shortMonthSymbols
        let columns = [GridItem(.adaptive(minimum: 80))]
        
        VStack(spacing: 30) {
            // Year picker
            HStack {
                decrease()
                
                Text(String(selectedDate.year))
                    .transition(.move(edge: .trailing))
                
                increase()
            }
            .font(.title3)
            .fontWeight(.bold)
            .foregroundStyle(.appWhite)
            
            // Month picker
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(months, id: \.self) { item in
                    Text(item)
                        .font(.headline).bold()
                        .frame(width: 60, height: 33)
                        .background(item == selectedDate.toString(format: .custom("MMM")) ? Color.appBlue : Color.gray.opacity(0.3), in: .rect(cornerRadius: 8))
                        .onTapGesture {
                            var dateComponents = DateComponents()
                            dateComponents.month = months.firstIndex(of: item)! + 1
                            dateComponents.year = selectedDate.year
                            selectedMonth = Calendar.current.date(from: dateComponents)!
                            dateComponents.day = 1
                            selectedDate = Calendar.current.date(from: dateComponents)!
                        }
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(.appBackground)
        .toolbar {
            Button {
                showMonthYearPicker = false
            } label: {
                Image(systemName: "xmark")
            }
        }
    }
    
    private func monthYearUpdate(increment: Bool = true, isMonth: Bool = false) {
        let calendar = Calendar.current
        
        guard let month = calendar.date(byAdding: isMonth ? .month : .year, value: increment ? 1 : -1, to: selectedMonth) else { return }
        guard let date = calendar.date(byAdding: isMonth ? .month : .year, value: increment ? 1 : -1, to: selectedDate) else { return }
        
        selectedDate = date
        withAnimation {
            selectedMonth = month
        }
    }
}
