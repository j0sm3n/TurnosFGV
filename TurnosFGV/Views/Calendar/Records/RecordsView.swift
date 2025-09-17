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
    
    // Transition namespace
    @Namespace private var transition
    @Namespace private var transition2
    private let transitionID = "newRecord"
    
    // SwiftData query
    @Query(sort: \WorkDay.startDate) private var workDays: [WorkDay]
    
    var body: some View {
        VStack {
            RecordsHeader
            RecordsScrollView
        }
    }
}

#if DEBUG
#Preview {
    VStack {
        VStack {}.frame(height: 400)
        RecordsView(selectedDate: .constant(.now), selectedMonth: .constant(.now.adjust(for: .startOfMonth)!))
            .modelContainer(WorkDay.preview)
    }
    .background(.appBackground)
}
#endif

extension RecordsView {
    @ViewBuilder
    private var RecordsHeader: some View {
        HStack {
            Text("Registros")
                .font(.title2.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Add Record Button
            if #available(iOS 26.0, *) {
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
                        .padding()
                }
                .glassEffect(.clear)
                .matchedTransitionSource(id: transitionID, in: transition)
                .alert("Ups!", isPresented: $showWorkedDayAlert) {
                    Button("Ok") {}
                } message: {
                    Text("Ya existe un turno el día \(selectedDate.toString(format: .custom("dd/MM/yyyy"))!)")
                }
            } else {
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
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var RecordsScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack {
                    ForEach(workDays) { workDay in
                        if #available(iOS 26.0, *) {
                            Button {
                                selectedWorkDay = workDay
                            } label: {
                                RecordRowView(workDay: workDay, selectedWorkDay: workDay.startDate.compare(.isSameDay(as: selectedDate)))
                                    .id(workDay.id)
                            }
                            .tint(.white)
                            .matchedTransitionSource(id: workDay.id, in: transition2)
                        } else {
                            Button {
                                selectedWorkDay = workDay
                            } label: {
                                RecordRowView(workDay: workDay, selectedWorkDay: workDay.startDate.compare(.isSameDay(as: selectedDate)))
                                    .id(workDay.id)
                            }
                            .tint(.white)
                        }
                    }
                }
                .padding(.horizontal)
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .task {
                if let record = getRecordOfDay(selectedDate) {
                    withAnimation {
                        proxy.scrollTo(record.id, anchor: .top)
                    }
                }
            }
            .onChange(of: selectedDate) {
                if let record = getRecordOfDay(selectedDate) {
                    withAnimation {
                        proxy.scrollTo(record.id, anchor: .top)
                    }
                }
                selectedMonth = selectedDate.adjust(for: .startOfMonth)!
            }
            .fullScreenCover(isPresented: $showNewRecordView, onDismiss: {
                if let record = getRecordOfDay(selectedDate) {
                    withAnimation {
                        proxy.scrollTo(record.id, anchor: .top)
                    }
                }
            }, content: {
                NavigationStack {
                    NewRecordView(date: selectedDate)
                        .navigationTransition(.zoom(sourceID: transitionID, in: transition))
                }
            })
            .sheet(item: $selectedWorkDay) { workDay in
                RecordDetailView(workDay: workDay)
                    .navigationTransition(.zoom(sourceID: workDay.id, in: transition2))
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
