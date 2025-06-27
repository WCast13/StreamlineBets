//
//  ScorecardSummary.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/27/25.
//

import SwiftUI
import SwiftData

// MARK: - ScorecardSummary
struct ScorecardSummary: View {
    let playerScore: PlayerScore
    let course: Course?
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Summary")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                SummaryItem(label: "Front 9", value: playerScore.front9Score)
                SummaryItem(label: "Back 9", value: playerScore.back9Score)
                SummaryItem(label: "Total", value: playerScore.score, isHighlighted: true)
            }
            
            if playerScore.winnings != 0 {
                Divider()
                
                HStack {
                    Text("Winnings")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(formatCurrency(playerScore.winnings))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(playerScore.winnings > 0 ? .green : .red)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}
