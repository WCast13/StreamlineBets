//
//  PlayerRowForRound.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/25/25.
//

import SwiftUI

struct PlayerRowForRound: View {
    let player: Player
    let game: Game
    let onRemove: () -> Void
    
    private var courseHandicap: Int {
        player.courseHandicap(
            courseRating: game.courseRating,
            slopeRating: game.slopeRating,
            par: game.par
        )
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(player.name)
                    .font(.body)
                
                HStack(spacing: 12) {
                    Label("\(player.handicapIndex, specifier: "%.1f")",
                          systemImage: "figure.golf")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("CH: \(courseHandicap)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
                    .imageScale(.medium)
            }
        }
        .padding(.vertical, 4)
    }
}

