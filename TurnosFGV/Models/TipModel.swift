//
//  TipModel.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 27/5/24.
//

import Foundation
import TipKit

struct SelectDateTip: Tip {
    let title: Text = Text("Selecciona una fecha.")
    let message: Text? = Text("Puedes ir directo a una fecha pulsando aquí.")
    let image: Image? = Image(systemName: "calendar")
}

struct ChartTip: Tip {
    let title: Text = Text("Toca la gráfica.")
    let message: Text? = Text("Puedes ver los detalles tocando en las gráficas.")
    let image: Image? = Image(systemName: "chart.bar.xaxis")
}
