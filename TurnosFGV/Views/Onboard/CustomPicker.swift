//
//  CustomPicker.swift
//  OnboardTest
//
//  Created by Jose Antonio Mendoza on 30/1/24.
//

import SwiftUI

protocol PickerEnum: Identifiable, Hashable, CaseIterable where AllCases == Array<Self> {
    var id: Self { get }
    var displayName: String { get }
}

struct CustomPicker<S: PickerEnum>: View where S.AllCases == Array<S> {
    var selection: Binding<S>
    
    init(selection: Binding<S>) {
        self.selection = selection
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.appPurple)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.white)], for: .selected)
    }
    
    var body: some View {
        Picker("", selection: selection) {
            ForEach(S.allCases, id: \.self) {
                Text($0.displayName)
                    .tag($0)
            }
        }
        .pickerStyle(.segmented)
    }
}
