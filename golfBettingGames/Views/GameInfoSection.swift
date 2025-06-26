//
//  GameInfoSection.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/19/25.
//

// MARK: - GameInfoSection.swift
import SwiftUI

struct GameInfoSection: View {
    let game: Game
    
    var body: some View {
        Section("Game Information") {
            HStack {
                Text("Game Type")
                Spacer()
                Text(game.gameType.description)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Course")
                Spacer()
                Text(game.courseName)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            HStack {
                Text("Course Rating/Slope")
                Spacer()
                Text("\(game.courseRating, specifier: "%.1f") / \(Int(game.slopeRating))")
                    .foregroundColor(.secondary)
            }
        }
    }
}
