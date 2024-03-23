//
//  RecordRowView.swift
//  RegistroTurnos2
//
//  Created by Jose Antonio Mendoza on 13/3/24.
//

import SwiftUI

struct RecordRowView: View {
    let workDay: WorkDay
    let selectedWorkDay: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.appPurple.gradient.shadow(.inner(color: .white, radius: selectedWorkDay ? 3 : 1)))
            HStack {
                Text(workDay.shift)
                    .shiftTextModifier(size: workDay.shift == "STDR" ? 18 : 40)
                    .frame(width: 60, alignment: .center)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(workDay.startDate.toString(format: .custom("dd MMM yyyy"))!)
                        .fontWeight(.semibold)
                    HStack {
                        Text(workDay.viewRecordDuration)
                        if workDay.extraTime > 0 {
                            Text("+ \(workDay.extraTime) minutos de exceso.")
                        }
                    }
                    .font(.caption)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 60)
    }
}

