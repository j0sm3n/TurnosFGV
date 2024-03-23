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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: WorkDay.self)
    }
}
