//
//  RoundSummaryRow.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/20/25.
//

import SwiftUI

struct RoundSummaryRow: View {
    let round: Round
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Round \(round.roundNumber)")
                    .font(.headline)
                
                if let holeNumber = round.holeNumber {
                    Text("Hole \(holeNumber)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(round.betAmount, specifier: "%.0f")")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(round.date.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
