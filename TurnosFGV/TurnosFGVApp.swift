//
//  TurnosFGVApp.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 21/3/24.
//

import SwiftData
import SwiftUI

/// SwiftData Models
typealias WorkDay = VersionedSchemaV1.WorkDay

@main
struct TurnosFGVApp: App {
    @AppStorage(Constants.currentOnboardingVersion) private var hasSeenOnboardingView = false
    let container: ModelContainer
    
    init() {
        do {
            #if DEBUG
            self.container = WorkDay.preview
            #else
            self .container = try ModelContainer(for: WorkDay.self)
            #endif
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
