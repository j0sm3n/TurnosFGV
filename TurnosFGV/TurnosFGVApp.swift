//
//  TurnosFGVApp.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 21/3/24.
//

import SwiftUI

/// SwiftData Models
typealias WorkDay = VersionedSchemaV1.WorkDay

@main
struct TurnosFGVApp: App {
    @AppStorage(Constants.currentOnboardingVersion) private var hasSeenOnboardingView = false

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboardingView {
                ContentView()
            } else {
                OnboardView()
            }
        }
        .modelContainer(for: WorkDay.self)
    }
}
