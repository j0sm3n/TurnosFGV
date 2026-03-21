//
//  RecordRowView.swift
//  RegistroTurnos2
//
//  Created by Jose Antonio Mendoza on 13/3/24.
//

import SwiftUI

enum WorkDayTag: String, Identifiable, CaseIterable {
    case allowance = "D"
    case holiday = "F"
    case specialHoliday = "FE"
    case mentoring = "P"
    case sick = "E"
    case accident = "A"
    case spp = "S"
    
    var id: Self { self }
}

struct RecordRowView: View {
    let workDay: WorkDay
    let selectedWorkDay: Bool
    
    private var shiftSize: CGFloat {
        workDay.shift.count > 3 ? 18 : workDay.shift.count > 2 ? 32 : 40
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.appPurple.gradient.shadow(.inner(color: .white, radius: selectedWorkDay ? 3 : 1)))
            HStack {
                Text(workDay.shift)
                    .shiftTextModifier(size: shiftSize)
                    .frame(width: 60, alignment: .center)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(workDay.startDate.toString("dd MMM yyyy"))
                        .fontWeight(.semibold)
                    HStack {
                        Text(workDay.viewRecordDuration)
                        if workDay.extraTime > 0 {
                            Text("+ \(workDay.extraTime) min")
                        }
                    }
                    .font(.caption)
                }
                
                Spacer()
                
                ViewThatFits {
                    Tags(workDay: workDay, rows: [GridItem()])
                    Tags(workDay: workDay, rows: [GridItem(), GridItem()])
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 60)
    }
}

#Preview {
    let workDay = WorkDay(shift: "1",
                          startDate: Date(isoDateTime: "2024-02-04T05:27:00+01:00")!,
                          endDate: Date(isoDateTime: "2024-02-04T13:36:00+01:00")!,
                          saturation: 72.1,
                          extraTime: 8,
                          isAllowance: false,
                          isFreeLicense: true,
                          isWorkedHoliday: true,
                          isSpecialWorkedHoliday: true,
                          isMentoring: true,
                          isPaidLicense: true,
                          isSickLeave: true,
                          isWorkAccident: true,
                          isSPP: true)
    
    RecordRowView(workDay: workDay, selectedWorkDay: true)
}

extension RecordRowView {
    struct Tags: View {
        let workDay: WorkDay
        let rows: [GridItem]
        
        var body: some View {
            LazyHGrid(rows: rows, spacing: 4) {
                ForEach(workDay.activeTags) { workDayTag in tag(workDayTag.rawValue) }
            }
            .padding(.trailing)
            .padding(.vertical, 6)
        }
        
        private func tag(_ text: String) -> some View {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.appBlue.gradient.shadow(.inner(color: .white, radius: 1)))
                    .frame(width: 24, height: 24)
                Text(text)
                    .font(.caption)
                    .bold()
            }
        }
    }
}
