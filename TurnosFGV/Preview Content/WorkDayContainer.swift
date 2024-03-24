//
//  WorkDayContainer.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 24/3/24.
//

import DateHelper
import Foundation
import SwiftData

extension WorkDay {
    @MainActor
    static var preview: ModelContainer {
        let container = try! ModelContainer(for: WorkDay.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        
        let rangeOfDaysInMonth: Range = Range(1...28)
        let rangeOfWorkedDays: Range = Range(15...20)
        
        let shiftGroups = ShiftsDataModel()
        
        for month in 1...12 {
            // The number of worked days in month
            var workedDays: Set<Int> = []
            
            while workedDays.count < Int.random(in: rangeOfWorkedDays) {
                let workedDayNumber = Int.random(in: rangeOfDaysInMonth)
                workedDays.insert(workedDayNumber)
            }
            
            for workedDayNumber in workedDays {
                if let shift = shiftGroups.shiftGroups.randomElement()?.shifts.randomElement() {
                    let startDate = Date(fromString: "2024-\(month)-\(workedDayNumber)", format: .isoDate)!
                        .adjust(for: .startOfDay)!
                        .addingTimeInterval(shift.startTime)
                    let endTime = startDate.addingTimeInterval(shift.duration)
                    
                    let workDay = WorkDay(
                        shift: shift.name,
                        startDate: startDate,
                        endDate: endTime,
                        saturation: shift.saturation)
                    
                    container.mainContext.insert(workDay)
                }
            }
        }
        
        return container
    }
}
