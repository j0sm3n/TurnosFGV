//
//  RecordDetailView.swift
//  RegistroTurnos2
//
//  Created by Jose Antonio Mendoza on 16/2/24.
//

import CloudStorage
import SwiftData
import SwiftUI

struct RecordDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @CloudStorage(Constants.locationKey) var location: String = ""

    @State private var viewModel: RecordDetailViewModel
    @FocusState private var isFocused: Bool

    init(viewModel: RecordDetailViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationStack {
            VStack {
                dateHeader
                ScrollView {
                    VStack(spacing: 20) {
                        shiftPicker
                        shiftStartAndEnd
                        shiftExtraOptions
                    }
                }
                .scrollIndicators(.hidden)
            }
            .padding()
            .background(.appBackground)
            .task {
                viewModel.loadShifts()
            }
            .toolbar {
                ToolbarItem(placement: .destructiveAction) {
                    Button(role: .destructive) {
                        viewModel.showDeleteAlert = true
                    }
                    .tint(.red)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        viewModel.updateRecord()
                        dismiss()
                    }
                    .tint(viewModel.updateWorkDay.color)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }
            }
            .alert("Borrar turno \(viewModel.shift?.name ?? "")", isPresented: $viewModel.showDeleteAlert) {
                Button("Borrar", role: .destructive) {
                    viewModel.deleteRecord()
                    dismiss()
                }
                Button("Cancelar", role: .cancel, action: {})
            } message: {
                Text("¿Seguro que quieres borrar el turno del día \(viewModel.updateWorkDay.startDate.toString("dd MMM"))?")
            }
        }
    }
}

#Preview {
    @Previewable let container = try! ModelContainer(
        for: WorkDay.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    @Previewable let workDay = WorkDay(
        shift: "1",
        startDate: Date(isoDateTime: "2024-02-04T05:27:00+01:00")!,
        endDate: Date(isoDateTime: "2024-02-04T13:36:00+01:00")!,
        saturation: 72.1,
        extraTime: 8,
        isAllowance: true
    )
    container.mainContext.insert(workDay)
    let viewModel = RecordDetailViewModel(
        workDay: workDay,
        repository: LiveWorkDayRepository(context: container.mainContext)
    )
    return RecordDetailView(viewModel: viewModel)
        .modelContainer(container)
}

extension RecordDetailView {
    // MARK: - Extracted views
    private var dateHeader: some View {
        VStack {
            Text(viewModel.updateWorkDay.startDate.formatted(date: .complete, time: .omitted))
                .font(.title.bold())
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)
                .padding(.bottom)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var shiftPicker: some View {
        @Bindable var viewModel = viewModel
        return ShiftPickerGroupBox(shiftsByLocation: viewModel.shiftsByLocation, selectedShift: $viewModel.shift)
            .onChange(of: viewModel.shift, initial: false) {
                viewModel.onShiftChanged(userLocation: location)
            }
    }

    private var shiftStartAndEnd: some View {
        GroupBox {
            LabeledContent("Inicio de jornada") {
                Text(viewModel.updateWorkDay.startDate, style: .time)
            }
            LabeledContent("Fin de jornada") {
                Text(viewModel.updateWorkDay.endDate, style: .time)
            }
        }
        .groupBoxBackGroundStyle()
    }

    private var shiftExtraOptions: some View {
        @Bindable var updateWorkDay = viewModel.updateWorkDay
        return GroupBox {
            LabeledContent("Duración", value: viewModel.updateWorkDay.workingHours)
            LabeledContent("Saturación", value: viewModel.updateWorkDay.saturation ?? 0, format: .number)
            LabeledContent("Nocturnidad", value: viewModel.updateWorkDay.nightTimeString)
            LabeledContent("Exceso de jornada") {
                HStack {
                    TextField("Minutos", value: $updateWorkDay.extraTime, formatter: NumberFormatter())
                        .frame(width: 80)
                        .multilineTextAlignment(.trailing)
                        .focused($isFocused)
                    Text("min")
                }
            }
            .contentShape(.rect)
            .onTapGesture { isFocused = true }
            WorkDayTogglesSection(workDay: viewModel.updateWorkDay)
        }
        .groupBoxBackGroundStyle()
        .tint(viewModel.updateWorkDay.color)
    }
}
