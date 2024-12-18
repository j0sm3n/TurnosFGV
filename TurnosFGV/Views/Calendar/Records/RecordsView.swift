//
//  RecordsView.swift
//  RegistroTurnos2
//
//  Created by Jose Antonio Mendoza on 15/3/24.
//

import SwiftData
import SwiftUI

struct RecordsView: View {
    // Binding month and date
    @Binding var selectedDate: Date
    @Binding var selectedMonth: Date
    
    // View properties
    @State private var showNewRecordView: Bool = false
    @State private var showWorkedDayAlert: Bool = false
    @State private var selectedWorkDay: WorkDay?
    
    // SwiftData query
    @Query(sort: \WorkDay.startDate, order: .reverse) private var workDays: [WorkDay]
    
    var body: some View {
        VStack {
            RecordsHeader
            RecordsScrollView
        }
    }
}

#Preview {
    RecordsView(selectedDate: .constant(.now), selectedMonth: .constant(.now.adjust(for: .startOfMonth)!))
        .modelContainer(for: WorkDay.self)
}

extension RecordsView {
    @ViewBuilder
    private var RecordsHeader: some View {
        HStack {
            Text("Registros")
                .font(.title2.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Add Record Button
            Button {
                if canWorkSelectedDate {
                    showNewRecordView = true
                } else {
                    showWorkedDayAlert = true
                }
            } label: {
                Image(systemName: "plus")
                    .font(.title.bold())
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .background(.appPurple.gradient.shadow(.inner(color: .white, radius: 2)), in: .rect(cornerRadius: 20))
            }
            .alert("Ups!", isPresented: $showWorkedDayAlert) {
                Button("Ok") {}
            } message: {
                Text("Ya existe un turno el día \(selectedDate.toString(format: .custom("dd/MM/yyyy"))!)")
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var RecordsScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack {
                    ForEach(workDays) { workDay in
                        Button {
                            selectedWorkDay = workDay
                        } label: {
                            RecordRowView(workDay: workDay, selectedWorkDay: workDay.startDate.compare(.isSameDay(as: selectedDate)))
                                .id(workDay.id)
                                .scrollTransition { view, transition in
                                    view
                                        .opacity(transition.isIdentity ? 1 : 0.2)
                                        .scaleEffect(transition.isIdentity ? 1 : 0.8)
                                }
                        }
                        .tint(.white)
                    }
                }
                .padding(.horizontal)
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .onChange(of: selectedDate) {
                if let record = getRecordOfDay(selectedDate) {
                    withAnimation {
                        proxy.scrollTo(record.id, anchor: .top)
                    }
                }
                selectedMonth = selectedDate.adjust(for: .startOfMonth)!
            }
            .sheet(isPresented: $showNewRecordView, onDismiss: {
                if let record = getRecordOfDay(selectedDate) {
                    withAnimation {
                        proxy.scrollTo(record.id, anchor: .top)
                    }
                }
            }, content: {
                NewRecordView(date: selectedDate)
            })
            .sheet(item: $selectedWorkDay) { workDay in
                NavigationStack {
                    RecordDetailView(workDay: workDay)
                }
            }
        }
    }
    
    var canWorkSelectedDate: Bool {
        getRecordOfDay(selectedDate) == nil
    }
    
    func getRecordOfDay(_ day: Date) -> WorkDay? {
        workDays.first(where: { $0.startDate.compare(.isSameDay(as: day)) })
    }
}
