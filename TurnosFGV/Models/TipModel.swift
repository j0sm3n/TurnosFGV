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

struct BarChartTip: Tip {
    let title: Text = Text("Toca una barra.")
    let message: Text? = Text("Puedes ver las horas de cada mes pulsando en la barra correspondiente.")
    let image: Image? = Image(systemName: "chart.bar.xaxis")
}

struct PieChartTip: Tip {
    let title: Text = Text("Toca un sector")
    let message: Text? = Text("Puedes ver las horas de cada tipo de turno pulsando en el sector correspondiente.")
    let image: Image? = Image(systemName: "chart.pie.fill")
}
