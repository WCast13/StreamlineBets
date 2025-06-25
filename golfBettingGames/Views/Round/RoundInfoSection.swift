//
//  RoundInfoSection.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/25/25.
//

import SwiftUI
import SwiftData

// MARK: - RoundInfoSection.swift
struct RoundInfoSection: View {
    let round: Round
    
    private var gameInfo: (name: String, course: String)? {
        guard let game = round.game else { return nil }
        return (game.name, game.courseName)
    }
    
    var body: some View {
        Section("Round Information") {
            if let gameInfo = gameInfo {
                LabeledContent("Game", value: gameInfo.name)
                LabeledContent("Course", value: gameInfo.course)
            }
            
            LabeledContent("Type", value: round.roundType.description)
            
            if let holeNumber = round.holeNumber {
                LabeledContent("Hole", value: "Hole \(holeNumber)")
            }
            
            LabeledContent("Bet Amount") {
                Text("$\(round.betAmount, specifier: "%.2f")")
                    .fontWeight(.medium)
            }
            
            LabeledContent("Date", value: round.date.formatted(date: .abbreviated, time: .shortened))
            
            HStack {
                Text("Status")
                Spacer()
                StatusBadge(isCompleted: round.isCompleted)
            }
        }
    }
}
