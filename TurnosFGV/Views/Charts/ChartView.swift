//
//  ChartView.swift
//  RegistroTurnos2
//
//  Created by Jose Antonio Mendoza on 3/3/24.
//

import SwiftUI

struct ChartView: View {
    var body: some View {
        ContentUnavailableView(
            "Resumen",
            systemImage: "chart.bar.xaxis",
            description: Text("Vista en construcción").foregroundStyle(.appWhite)
        )
        .foregroundStyle(.appPurple)
        .background(.appBackground)
    }
}

#Preview {
    ChartView()
}
