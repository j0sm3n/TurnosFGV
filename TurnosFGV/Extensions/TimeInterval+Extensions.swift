//
//  TimeInterval+Extensions.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 21/3/24.
//

import Foundation

extension TimeInterval {
    init(hour: Int, minute: Int = 0) {
        self = TimeInterval((hour * 3600) + (minute * 60))
    }
}
