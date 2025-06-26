//
//  WinningsSection.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/25/25.
//

import SwiftUI
import SwiftData

// MARK: - WinningsSection.swift
struct WinningsSection: View {
    let round: Round
    
    private var totalPot: Double {
        round.betAmount * Double(round.scores.count)
    }
    
    private var winners: [PlayerScore] {
        round.scores.filter { $0.winnings > 0 }
            .sorted { $0.winnings > $1.winnings }
    }
    
    var body: some View {
        Section("Results") {
            LabeledContent("Total Pot") {
                Text("$\(totalPot, specifier: "%.2f")")
                    .fontWeight(.medium)
            }
            
            if !winners.isEmpty {
                ForEach(winners) { winner in
                    HStack {
                        Label(winner.player?.name ?? "Unknown",
                              systemImage: "trophy.fill")
                            .foregroundColor(.orange)
                        
                        Spacer()
                        
                        Text("+$\(winner.winnings, specifier: "%.2f")")
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                    }
                }
            }
        }
    }
}
