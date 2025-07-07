//
//  ScoresSection.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/25/25.
//

import SwiftUI
import SwiftData

// MARK: - ScoresSection.swift
struct ScoresSection: View {
    let scores: [PlayerScore]
    let round: Round
    @Binding var editingScore: PlayerScore?
    
    var body: some View {
        Section("Scores") {
            ForEach(scores) { score in
                ScoreRowView(
                    score: score,
                    round: round,
                    onTap: { editingScore = score }
                )
            }
        }
    }
}

