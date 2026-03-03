//
//  ToggleRow.swift
//  TurnosFGV
//

import SwiftUI

struct ToggleRow: View {
    let label: String
    @Binding var isOn: Bool

    init(_ label: String, isOn: Binding<Bool>) {
        self.label = label
        self._isOn = isOn
    }

    var body: some View {
        LabeledContent(label) { Toggle("", isOn: $isOn) }
    }
}
