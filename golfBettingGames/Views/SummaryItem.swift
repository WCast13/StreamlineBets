//
//  SummaryItem.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/27/25.
//

import SwiftUI
import SwiftData

// MARK: - SummaryItem
struct SummaryItem: View {
    let label: String
    let value: Int
    var isHighlighted = false
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value > 0 ? "\(value)" : "-")
                .font(isHighlighted ? .title : .title2)
                .fontWeight(isHighlighted ? .bold : .semibold)
                .foregroundColor(isHighlighted ? .accentColor : .primary)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
