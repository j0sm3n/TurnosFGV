//
//  NewRecordView.swift
//  RegistroTurnos2
//
//  Created by Jose Antonio Mendoza on 17/2/24.
//

import CloudStorage
import SwiftData
import SwiftUI

struct NewRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @CloudStorage(Constants.locationKey) var location: String = ""

    @State private var viewModel: NewRecordViewModel

    init(viewModel: NewRecordViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                shiftPicker
                shiftStartAndEnd
                shiftExtraOptions
            }
        }
        .padding(15)
        .background(.appBackground)
        .task {
            viewModel.loadShifts()
        }
        .onChange(of: viewModel.selectedShift) {
            viewModel.onShiftSelected(userLocation: location)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .cancel) {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm) {
                    viewModel.save()
                    dismiss()
                }
                .tint(viewModel.selectedShift?.color ?? .clear)
                .disabled(!viewModel.canSave)
            }
        }
    }
}

#Preview {
    @Previewable let container = try! ModelContainer(
        for: WorkDay.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let viewModel = NewRecordViewModel(
        date: .now,
        repository: LiveWorkDayRepository(context: container.mainContext)
    )
    NavigationStack {
        NewRecordView(viewModel: viewModel)
    }
    .modelContainer(container)
}

extension NewRecordView {
    // MARK: - Extracted views
    private var shiftPicker: some View {
        @Bindable var viewModel = viewModel
        return ShiftPickerGroupBox(shiftsByLocation: viewModel.shiftsByLocation, selectedShift: $viewModel.selectedShift)
    }

    private var shiftStartAndEnd: some View {
        GroupBox {
            LabeledContent("Inicio") {
                Text(viewModel.draft.startDate.toString("dd/MM/yyyy HH:mm"))
                    .monospaced()
            }
            LabeledContent("Fin") {
                Text(viewModel.draft.endDate.toString("dd/MM/yyyy HH:mm"))
                    .monospaced()
            }
        }
        .groupBoxBackGroundStyle()
    }

    private var shiftExtraOptions: some View {
        GroupBox {
            WorkDayTogglesSection(workDay: viewModel.draft)
        }
        .tint(viewModel.selectedShift?.color ?? .appYellow)
        .groupBoxBackGroundStyle()
    }
}
