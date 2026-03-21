//
//  WorkDayRepository.swift
//  TurnosFGV
//

import SwiftData

/// Persistence boundary for WorkDay CRUD operations.
/// Abstracts SwiftData's ModelContext so ViewModels remain testable without a live container.
@MainActor
protocol WorkDayRepository {
    func fetchAll() throws -> [WorkDay]
    func insert(_ workDay: WorkDay)
    func delete(_ workDay: WorkDay)
}

/// Live implementation backed by a SwiftData ModelContext.
@MainActor
final class LiveWorkDayRepository: WorkDayRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [WorkDay] {
        try context.fetch(WorkDay.allWorkDaysDescriptor())
    }

    func insert(_ workDay: WorkDay) {
        context.insert(workDay)
    }

    func delete(_ workDay: WorkDay) {
        context.delete(workDay)
    }
}
