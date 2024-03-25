//
//  OnboardView.swift
//  OnboardTest
//
//  Created by Jose Antonio Mendoza on 30/1/24.
//

import SwiftUI

struct OnboardStepView<T: PickerEnum>: View {
    var id = UUID()
    let systemImageName: String
    let title: String
    let description: String
    @Binding var item: T

    var body: some View {
        ScrollView {
            VStack {
                Image(systemName: systemImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .foregroundStyle(.appPurple)
                    .padding(.bottom, 50)
                
                Text(title)
                    .font(.title.bold())
                
                Text(description)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.appWhite)
                    .padding(.vertical, 20)
                
                SegmentedControl(
                    activeTab: $item,
                    activeTint: .appWhite,
                    inActiveTint: .gray) { size in
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.appPurple)
                            .frame(height: size.height)
                            .padding(.horizontal, 0)
                            .offset(y: 0)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                    }
                    .padding(.top, 0)
                    .background {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.ultraThinMaterial)
                            .ignoresSafeArea()
                    }
                    .padding(.horizontal, 15)
            }
            .padding(.horizontal, 40)
            .padding(.top, 100)
        }
    }
}
