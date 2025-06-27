//
//  StatView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/27/25.
//

import SwiftUI
import SwiftData

// MARK: - StatView
struct StatView: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
