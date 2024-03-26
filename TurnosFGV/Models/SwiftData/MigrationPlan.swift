//
//  MigrationPlan.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 26/3/24.
//

import Foundation
import SwiftData

enum MigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [VersionedSchemaV1.self]
    }
    
    static var stages: [MigrationStage] {
        []
    }
}
