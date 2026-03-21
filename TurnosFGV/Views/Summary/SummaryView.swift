//
//  SummaryView.swift
//  TurnosFGV
//
//  Created by Jose Antonio Mendoza on 25/3/24.
//

import SwiftUI
import SwiftData
import CloudStorage

struct SummaryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(DateSelectionViewModel.self) var dateVM
    @CloudStorage(Constants.prevYearHoursKey) var prevYearHours: Double = 0.0
    @State private var viewModel = PayrollViewModel()
    @State private var showPayrollGroup: Bool = true

    var body: some View {
        NavigationStack {
            VStack {
                MonthYearHeader()
                ScrollView {
                    switch viewModel.loadState {
                    case .failed(let message):
                        ContentUnavailableView("Error al cargar", systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.appWhite)
                            .offset(y: 200)
                            .accessibilityLabel(message)
                    default:
                        if viewModel.recordsInMonth.isEmpty {
                            ContentUnavailableView("No hay registros", systemImage: "doc.text.magnifyingglass")
                                .foregroundStyle(.appWhite)
                                .offset(y: 200)
                        } else {
                            payrollDisclosureGroup
                            monthDisclosureGroup
                            yearDisclosureGroup
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
            .background(.appBackground)
            .task(id: dateVM.currentDate.startOfMonth) {
                viewModel.selectedDate = dateVM.currentDate
                viewModel.load(using: LiveWorkDayRepository(context: modelContext))
            }
            .onChange(of: dateVM.currentDate) { _, newDate in
                viewModel.selectedDate = newDate
            }
        }
    }
}

#Preview {
    SummaryView()
    #if DEBUG
        .modelContainer(WorkDay.preview)
        .environment(DateSelectionViewModel())
    #endif
}

extension SummaryView {
    // MARK: - Extracted views
    private var payrollDisclosureGroup: some View {
        DisclosureGroup(isExpanded: $showPayrollGroup) {
            VStack(spacing: 12) {
                LabeledContent("Nocturnidad", value: viewModel.nightTimeInMonth, format: .number.precision(.fractionLength(0)))
                LabeledContent("Comp. Jor. Cont. Peculiares", value: viewModel.noonRecordsCount, format: .number)
                LabeledContent("Prima saturación maquinista", value: viewModel.saturationInMonth, format: .number.precision(.fractionLength(0)))
                LabeledContent("Indemnización Domingo/Festivo", value: viewModel.sundaysOrWorkedHolidaysInMonth, format: .number)
                LabeledContent("Indemnización descanso bocadillo", value: viewModel.snackBreakCompensation, format: .number)
                LabeledContent("Indemnización sábados", value: viewModel.saturdaysInMonth, format: .number)
                LabeledContent("Horas extras extructurales", value: viewModel.extraTimeInMonth, format: .number.precision(.fractionLength(2)))
                    .hide(if: viewModel.extraTimeInMonth == 0)
                LabeledContent("SPP", value: viewModel.totalSPPHours, format: .number.precision(.fractionLength(2)))
                    .hide(if: viewModel.totalSPPHours == 0)
                LabeledContent("Dietas", value: viewModel.numberOfAllowance, format: .number.precision(.fractionLength(2)))
                    .hide(if: viewModel.numberOfAllowance == 0)
                LabeledContent("Comp. Festivos Especiales", value: viewModel.numberOfSpecialWorkedHolidays, format: .number)
                    .hide(if: viewModel.numberOfSpecialWorkedHolidays == 0)
            }
            .padding(.bottom)
        } label: {
            Label("Nómina \(dateVM.currentMonth.toString("MMMM yyyy"))", systemImage: "doc.text.magnifyingglass")
                .disclosureGroupLabelStyle()
        }
        .disclosureGroupBackgroundStyle()
    }

    private var monthDisclosureGroup: some View {
        DisclosureGroup {
            VStack(spacing: 12) {
                LabeledContent("Horas trabajadas", value: viewModel.monthWorkedHours, format: .number.precision(.fractionLength(2)))

                LabeledContent("Dias trabajados", value: viewModel.workedDaysInCurrentMonth, format: .number)

                ForEach(TypeOfShift.allCases) { typeOfShift in
                    let (hours, days) = viewModel.recordsByType(viewModel.recordsInMonth, typeOfShift)
                    LabeledContent("\(typeOfShift.rawValue) (\(days))", value: hours, format: .number.precision(.fractionLength(2)))
                }
            }
            .padding(.bottom)
        } label: {
            Label("Datos de \(dateVM.currentMonth.toString("MMMM"))", systemImage: "\(dateVM.currentMonth.component(.month)).square.fill")
                .disclosureGroupLabelStyle()
        }
        .disclosureGroupBackgroundStyle()
    }

    private var yearDisclosureGroup: some View {
        DisclosureGroup {
            VStack(spacing: 12) {
                LabeledContent("Horas trabajadas", value: viewModel.yearWorkedHours, format: .number.precision(.fractionLength(2)))

                LabeledContent("Horas año anterior", value: prevYearHours, format: .number.precision(.fractionLength(2)))

                LabeledContent("Dias trabajados", value: viewModel.workedDaysInCurrentYear, format: .number)

                ForEach(TypeOfShift.allCases, id: \.self) { typeOfShift in
                    let (hours, days) = viewModel.recordsByType(viewModel.recordsInYear, typeOfShift)
                    LabeledContent("\(typeOfShift.rawValue) (\(days))", value: hours, format: .number.precision(.fractionLength(2)))
                }
            }
            .padding(.bottom)
        } label: {
            Label("Datos de \(String(dateVM.currentMonth.year))", systemImage: "calendar")
                .disclosureGroupLabelStyle()
        }
        .disclosureGroupBackgroundStyle()
    }
}
