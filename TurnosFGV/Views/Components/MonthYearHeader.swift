//
//  MonthYearHeader.swift
//  RegistroTurnos2
//
//  Created by Jose Antonio Mendoza on 3/3/24.
//

import SwiftUI

struct MonthYearHeader: View {
    @Environment(DateSelectionViewModel.self) var dateVM

    @State private var showMonthYearPicker: Bool = false
    @State private var selectDateTip = SelectDateTip()

    var body: some View {
        @Bindable var dateVM = dateVM
        HStack {
            Button {
                selectDateTip.invalidate(reason: .actionPerformed)
                showMonthYearPicker.toggle()
            } label: {
                HStack {
                    Text(dateVM.currentMonth.toString("MMMM"))
                        .foregroundStyle(.appWhite)
                    Text(String(dateVM.currentMonth.year))
                        .foregroundStyle(.appPurple)
                }
                .font(.title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .popoverTip(selectDateTip)

            HStack(spacing: 15) {
                decrease(isMonth: true)

                Button {
                    dateVM.currentDate = Date.now
                    withAnimation {
                        dateVM.currentMonth = Date.now.startOfMonth
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
    MonthYearHeader()
        .environment(DateSelectionViewModel())
}

extension MonthYearHeader {
    private func decrease(isMonth: Bool = false) -> some View {
        Button {
            monthYearUpdate(increment: false, isMonth: isMonth)
        } label: {
            Image(systemName: "chevron.left")
                .padding(8)
                .contentShape(.rect)
        }
    }

    private func increase(isMonth: Bool = false) -> some View {
        Button {
            monthYearUpdate(increment: true, isMonth: isMonth)
        } label: {
            Image(systemName: "chevron.right")
                .padding(8)
                .contentShape(.rect)
        }
    }

    @ViewBuilder
    private var monthYearPicker: some View {
        @Bindable var dateVM = dateVM
        let months: [String] = Calendar.current.shortMonthSymbols
        let columns = [GridItem(.adaptive(minimum: 80))]

        VStack(spacing: 30) {
            // Year picker
            HStack {
                decrease()

                Text(String(dateVM.currentDate.year))
                    .transition(.move(edge: .trailing))

                increase()
            }
            .font(.title3)
            .fontWeight(.bold)
            .foregroundStyle(.appWhite)

            // Month picker
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(Array(months.enumerated()), id: \.offset) { index, item in
                    Button {
                        selectMonth(index: index, from: months, dateVM: dateVM)
                    } label: {
                        Text(item)
                            .font(.headline).bold()
                            .frame(width: 60, height: 33)
                            .background(item == dateVM.currentDate.toString("MMM") ? Color.appBlue : Color.gray.opacity(0.3), in: .rect(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
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
        @Bindable var dateVM = dateVM
        let calendar = Calendar.current

        guard let month = calendar.date(byAdding: isMonth ? .month : .year, value: increment ? 1 : -1, to: dateVM.currentMonth) else { return }
        guard let date = calendar.date(byAdding: isMonth ? .month : .year, value: increment ? 1 : -1, to: dateVM.currentDate) else { return }

        dateVM.currentDate = date
        withAnimation {
            dateVM.currentMonth = month
        }
    }

    private func selectMonth(index: Int, from months: [String], dateVM: DateSelectionViewModel) {
        var components = DateComponents()
        components.month = index + 1
        components.year = dateVM.currentDate.year
        components.day = 1
        guard let newDate = Calendar.current.date(from: components) else { return }
        dateVM.currentDate = newDate
        dateVM.currentMonth = newDate
    }
}
