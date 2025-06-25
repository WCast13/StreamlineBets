//
//  ScoreRowView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/25/25.
//

import SwiftUI
import SwiftData

// MARK: - ScoreRowView.swift
struct ScoreRowView: View {
    @Bindable var score: PlayerScore
    let round: Round
    let onTap: () -> Void
    
    private var courseHandicap: Int {
        guard let player = score.player,
              let game = round.game else { return 0 }
        
        return player.courseHandicap(
            courseRating: game.courseRating,
            slopeRating: game.slopeRating,
            par: game.par
        )
    }
    
    private var strokesReceived: Int {
        // For single hole, calculate strokes based on hole handicap
        if round.roundType == .hole, let holeNumber = round.holeNumber {
            // Assuming standard stroke allocation
            return courseHandicap >= holeNumber ? 1 : 0
        }
        return courseHandicap
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(score.player?.name ?? "Unknown")
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 12) {
                        if score.score > 0 {
                            Label("\(score.score)", systemImage: "flag.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("Net: \(score.netScore)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(4)
                        } else {
                            Text("Tap to enter score")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        
                        if strokesReceived > 0 {
                            Text("(\(strokesReceived) strokes)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                if score.winnings != 0 {
                    Text(formatCurrency(score.winnings))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(score.winnings > 0 ? .green : .red)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}
