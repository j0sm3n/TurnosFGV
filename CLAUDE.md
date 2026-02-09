# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TurnosFGV is a native iOS app (Swift/SwiftUI) for tracking work shifts and payroll calculations for railway workers at FGV (Ferrocarrils de la Generalitat Valenciana) in Spain. The UI and all domain terminology are in Spanish.

## Build & Run

- **IDE:** Xcode (open `TurnosFGV.xcodeproj`)
- **Simulador de desarrollo:** `188C34AD-4857-466D-B827-C3CC1FA8F6E5`
- **Build:** `xcodebuild -project TurnosFGV.xcodeproj -scheme TurnosFGV -destination "platform=iphonesimulator,id=188C34AD-4857-466D-B827-C3CC1FA8F6E5" -derivedDataPath DerivedData -configuration Debug build 2>&1 | xcbeautify -w`
- **Deployment target:** iOS 26.0
- **Swift version:** 5.0
- **Dependencies:** Managed via Swift Package Manager (resolved automatically by Xcode)
- **No test target exists** — validation is done through SwiftUI Previews

## Architecture

SwiftUI + SwiftData app following an MVVM-like pattern with four main tabs:

1. **Calendario** — Calendar grid with shift records per day
2. **Nómina** — Payroll summary with detailed compensation breakdowns
3. **Resumen** — Charts (bar chart for monthly hours, pie chart for shift type distribution)
4. **Ajustes** — Settings (role, location, previous year hour balance)

### Data Layer

- **SwiftData** persists `WorkDay` records (the core model). Schema is versioned via `VersionedSchemaV1` with a `MigrationPlan` for future migrations.
- **CloudStorage** (iCloud key-value store) syncs user preferences (role, location, previous year hours) across devices.
- The global typealias `WorkDay = VersionedSchemaV1.WorkDay` is defined in `TurnosFGVApp.swift`.

### Domain Model

- **WorkDay** (`Models/SwiftData/VersionedSchemaV1.swift`): Core persistent model representing a single shift record with properties for shift name, start/end dates, saturation, extra time, and various boolean flags (allowance, sick leave, SPP, holidays, etc.).
- **ShiftsDataModel** (`Models/ShiftsDataModel.swift`): Hard-coded shift schedule definitions organized by `ShiftGroup` (valid-from date × role × location). Contains multiple versions of shift schedules dating from July 2023 onward. Each `Shift` has a name, start time, duration, and optional saturation percentage.
- **Roles:** `maquinista`, `usi`
- **Locations:** `benidorm`, `denia`, `campello`
- **Shift types:** `morning` (Mañana), `noon` (Intermedio), `afternoon` (Tarde) — determined by start/end times

### Key Patterns

- **Extensions** in `Extensions/` add computed properties and query helpers to models (e.g., `WorkDay+Extensions` provides worked hours calculation, night time computation, and SwiftData `FetchDescriptor` builders).
- **View modifiers** in `Views/Modifiers/` provide reusable styling (glass effects, group box backgrounds, disclosure group styling).
- **Custom colors** defined in `Assets.xcassets/Colors/` (appBackground, appBlue, appOrange, appPurple, appWhite, appYellow) with luminance-based adaptive text color logic in `Color+Extensions`.
- **Preview data** is generated via `WorkDayContainer.swift` in `Preview Content/`.

## Project Structure

```
TurnosFGV/
├── TurnosFGVApp.swift          # Entry point, ModelContainer + TipKit setup
├── Models/
│   ├── SwiftData/              # WorkDay model, schema versioning, migrations
│   ├── ShiftsDataModel.swift   # Shift schedules per role/location/version
│   ├── ChartDataTypes.swift    # Chart data structures
│   ├── Day.swift               # Calendar day model
│   └── TipModel.swift          # TipKit models
├── Views/
│   ├── ContentView.swift       # Tab-based root view
│   ├── Calendar/               # Calendar grid + record CRUD views
│   ├── Summary/                # Payroll calculations
│   ├── Charts/                 # Bar and pie chart views
│   ├── Settings/               # User preferences
│   ├── Onboard/                # First-launch onboarding flow
│   ├── Components/             # Shared UI components
│   └── Modifiers/              # Custom ViewModifiers
├── Extensions/                 # Type extensions (Date, WorkDay, Color, View, etc.)
├── Helpers/
│   └── Constants.swift         # App-wide constants
└── Assets.xcassets/            # App icon, accent color, custom color palette
```

## Dependencies (SPM)

- **DateHelper** (`melvitax/DateHelper`) — Date parsing and formatting utilities
- **CloudStorage** (`nonstrict-hq/CloudStorage`) — iCloud key-value store property wrapper
- **Algorithms** (`apple/swift-algorithms`) — Swift collection algorithms

## Key Domain Concepts

- **STDR shifts** serve as the baseline hours reference for calculations
- **Saturation** (`prima de saturación`) is a percentage-based bonus per shift
- **Nocturnidad** is computed from hours worked between 22:00–06:00
- Payroll (Nómina) includes: night hours, complementary pay, saturation bonus, Sunday/holiday compensation, Saturday pay, structural extra hours, SPP, meal allowances (dietas), and previous year hour balance
- **Shift schedule versions** change over time; the correct version is selected by matching the work date against each `ShiftGroup.validFrom` date

## Localization

- Primary language: Spanish (es-ES)
- String Catalogs enabled (`LOCALIZATION_PREFERS_STRING_CATALOGS = YES`)
