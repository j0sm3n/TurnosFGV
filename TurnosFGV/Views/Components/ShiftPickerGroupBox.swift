//
//  ShiftPickerGroupBox.swift
//  TurnosFGV
//

import SwiftUI

struct ShiftPickerGroupBox: View {
    let shiftsByLocation: [String: [Shift]]
    @Binding var selectedShift: Shift?
    var placeholder: String = "Selecciona turno"

    private var locations: [String] { shiftsByLocation.keys.sorted() }
    private func shiftsOf(_ loc: String) -> [Shift] { shiftsByLocation[loc]?.sorted() ?? [] }

    var body: some View {
        GroupBox {
            LabeledContent("Turno") {
                Menu {
                    ForEach(locations, id: \.self) { loc in
                        Picker(loc, selection: $selectedShift) {
                            ForEach(shiftsOf(loc)) { shift in
                                Text(shift.name).tag(shift as Shift?)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                } label: {
                    Text(selectedShift?.name ?? placeholder)
                        .shiftTextModifier(color: selectedShift?.color ?? .white.opacity(0.6))
                }
            }
        }
        .groupBoxBackGroundStyle()
    }
}
