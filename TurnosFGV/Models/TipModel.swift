//
//  TipModel.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 27/5/24.
//

import Foundation
import TipKit

enum TipModel: Tip {
    case selectNewDate
    
    var title: Text {
        switch self {
        case .selectNewDate:
            Text("Selecciona una fecha.")
        }
    }
    
    var message: Text? {
        switch self {
        case .selectNewDate:
            Text("Puedes ir directo a una fecha pulsando aquí.")
        }
    }
    
    var image: Image? {
        switch self {
        case .selectNewDate:
            Image(systemName: "calendar")
        }
    }
}
