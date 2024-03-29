//
//  TurnosFGVApp.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 21/3/24.
//

import CloudStorage
import SwiftData
import SwiftUI

/// SwiftData Models
typealias WorkDay = VersionedSchemaV1.WorkDay

@main
struct TurnosFGVApp: App {
    @CloudStorage(Constants.currentOnboardingVersion) private var hasSeenOnboardingView = false
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([WorkDay.self])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            self.container = try ModelContainer(for: WorkDay.self, migrationPlan: MigrationPlan.self, configurations: config)
        } catch {
            fatalError("Could not configure the container")
        }
    }

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboardingView {
                ContentView()
            } else {
                OnboardView()
            }
        }
        .modelContainer(container)
    }
}
