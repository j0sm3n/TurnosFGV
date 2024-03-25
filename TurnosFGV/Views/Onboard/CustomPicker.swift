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

struct SegmentedControl<Indicator: View, S: PickerEnum>: View where S.AllCases == Array<S> {
    @Binding var activeTab: S
    var height: CGFloat = 45

    /// Customization Properties
    var font: Font = .title3
    var activeTint: Color
    var inActiveTint: Color

    /// Indicator View
    @ViewBuilder var indicatorView: (CGSize) -> Indicator

    /// View Properties
    @State private var excessTabWidth: CGFloat = .zero
    @State private var minX: CGFloat = .zero

    var body: some View {
        GeometryReader {
            let size = $0.size
            let containerWidthForEachTab = size.width / CGFloat(S.allCases.count)
            
            HStack(spacing: 0) {
                ForEach(S.allCases) { tab in
                    Text(tab.displayName)
                    .font(font)
                    .foregroundStyle(activeTab == tab ? activeTint : inActiveTint)
                    .animation(.snappy, value: activeTab)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(.rect)
                    .onTapGesture {
                        if let index = S.allCases.firstIndex(of: tab), let activeIndex = S.allCases.firstIndex(of: activeTab) {
                            activeTab = tab
                            
                            withAnimation(.snappy(duration: 0.1, extraBounce: 0), completionCriteria: .logicallyComplete) {
                                excessTabWidth = containerWidthForEachTab * CGFloat(index - activeIndex)
                            } completion: {
                                withAnimation(.snappy(duration: 0.1, extraBounce: 0)) {
                                    minX = containerWidthForEachTab * CGFloat(index)
                                    excessTabWidth = 0
                                }
                            }
                        }
                    }
                    .background(alignment: .leading) {
                        if S.allCases.first == tab {
                            GeometryReader {
                                let size = $0.size
                                
                                indicatorView(size)
                                    .frame(width: size.width + (excessTabWidth < 0 ? -excessTabWidth : excessTabWidth), height: size.height)
                                    .frame(width: size.width, alignment: excessTabWidth < 0 ? .trailing : .leading)
                                    .offset(x: minX)
                            }
                        }
                    }
                }
            }
            .preference(key: SizeKey.self, value: size)
            .onPreferenceChange(SizeKey.self) { size in
                if let index = S.allCases.firstIndex(of: activeTab) {
                    minX = containerWidthForEachTab * CGFloat(index)
                    excessTabWidth = 0
                }
            }
        }
        .frame(height: height)
    }
}

fileprivate struct SizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
