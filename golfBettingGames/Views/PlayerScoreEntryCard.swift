//
//  PlayerScoreEntryCard.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/27/25.
//

import SwiftUI
import SwiftData

// MARK: - PlayerScoreEntryCard
struct PlayerScoreEntryCard: View {
    let playerScore: PlayerScore
    let currentHole: Int
    @Binding var score: Int
    let holeInfo: Hole?
    
    private var strokesOnHole: Int {
        guard let player = playerScore.player,
              let round = playerScore.round,
              let game = round.game,
              let hole = holeInfo else { return 0 }
        
        let courseHandicap = player.courseHandicap(
            courseRating: game.effectiveRating,
            slopeRating: Double(game.effectiveSlope),
            par: game.par
        )
        
        return courseHandicap >= hole.handicap ? 1 : 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(playerScore.player?.name ?? "Unknown")
                    .font(.headline)
                
                Spacer()
                
                if strokesOnHole > 0 {
                    Text("Gets \(strokesOnHole) stroke(s)")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            // Score Selection
            VStack(alignment: .leading) {
                Text("Score")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(1...10, id: \.self) { num in
                            Button(action: { score = num }) {
                                Text("\(num)")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(score == num ? .semibold : .regular)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        score == num ? Color.accentColor : Color.gray.opacity(0.2)
                                    )
                                    .foregroundColor(score == num ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            
            if score > 0 && strokesOnHole > 0 {
                HStack {
                    Text("Net Score: \(score - strokesOnHole)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}
