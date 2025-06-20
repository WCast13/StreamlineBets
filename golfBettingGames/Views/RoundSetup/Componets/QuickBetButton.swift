//
//  QuickBetView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/19/25.
//

import SwiftUI

struct QuickBetButton: View {
    let amount: Int
    let isSelected: Bool
    let formatter: NumberFormatter
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)")
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
    }
}
//
//#Preview {
//    QuickBetButton(amount: , isSelected: <#Bool#>, formatter: <#NumberFormatter#>, action: <#() -> Void#>)
//}
