//
//  RecordsView.swift
//  RegistroTurnos2
//
//  Created by Jose Antonio Mendoza on 15/3/24.
//

import SwiftData
import SwiftUI

struct RecordsView: View {
    @Environment(\.modelContext) private var modelContext

    // Binding month and date
    @Binding var selectedDate: Date
    @Binding var selectedMonth: Date

    // View properties
    @State private var showNewRecordView: Bool = false
    @State private var showWorkedDayAlert: Bool = false
    @State private var selectedWorkDay: WorkDay?

    // Transition namespace
    @Namespace private var transition
    @Namespace private var recordTransition
    private let transitionID = "newRecord"

    // SwiftData query
    @Query(sort: \WorkDay.startDate) private var workDays: [WorkDay]

    var body: some View {
        VStack {
            recordsHeader
            recordsScrollView
        }
    }
}

#if DEBUG
#Preview {
    VStack {
        VStack {}.frame(height: 400)
        RecordsView(selectedDate: .constant(.now), selectedMonth: .constant(.now.startOfMonth))
            .modelContainer(WorkDay.preview)
    }
    .background(.appBackground)
}
#endif

extension RecordsView {
    @ViewBuilder
    private var recordsHeader: some View {
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
                    .padding()
            }
            .glassEffect(.clear)
            .matchedTransitionSource(id: transitionID, in: transition)
            .alert("Ups!", isPresented: $showWorkedDayAlert) {
                Button("Ok") {}
            } message: {
                Text("Ya existe un turno el día \(selectedDate.toString("dd/MM/yyyy"))")
            }
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var recordsScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack {
                    ForEach(workDays) { workDay in
                        Button {
                            selectedWorkDay = workDay
                        } label: {
                            RecordRowView(workDay: workDay, selectedWorkDay: workDay.startDate.isSameDay(as: selectedDate))
                                .id(workDay.id)
                        }
                        .tint(.white)
                        .matchedTransitionSource(id: workDay.id, in: recordTransition)
                    }
                }
                .padding(.horizontal)
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .onChange(of: selectedDate, initial: true) {
                if let record = getRecordOfDay(selectedDate) {
                    withAnimation {
                        proxy.scrollTo(record.id, anchor: .top)
                    }
                }
                selectedMonth = selectedDate.startOfMonth
            }
            .fullScreenCover(isPresented: $showNewRecordView, onDismiss: {
                if let record = getRecordOfDay(selectedDate) {
                    withAnimation {
                        proxy.scrollTo(record.id, anchor: .top)
                    }
                }
            }, content: {
                let viewModel = NewRecordViewModel(
                    date: selectedDate,
                    repository: LiveWorkDayRepository(context: modelContext)
                )
                NavigationStack {
                    NewRecordView(viewModel: viewModel)
                        .navigationTransition(.zoom(sourceID: transitionID, in: transition))
                }
            })
            .sheet(item: $selectedWorkDay) { workDay in
                let viewModel = RecordDetailViewModel(
                    workDay: workDay,
                    repository: LiveWorkDayRepository(context: modelContext)
                )
                RecordDetailView(viewModel: viewModel)
                    .navigationTransition(.zoom(sourceID: workDay.id, in: recordTransition))
            }
        }
    }

    private var canWorkSelectedDate: Bool {
        getRecordOfDay(selectedDate) == nil
    }

    private func getRecordOfDay(_ day: Date) -> WorkDay? {
        workDays.first(where: { $0.startDate.isSameDay(as: day) })
    }
}
