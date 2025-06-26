//
//  PlayerScore.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/25/25.
//


import Foundation
import SwiftData


// MARK: - Updated PlayerScore Model
@Model
final class PlayerScore {
    var id: UUID
    var totalGrossScore: Int
    var totalNetScore: Int
    var winnings: Double
    var notes: String
    
    // Relationships
    var player: Player?
    var round: Round?
    
    @Relationship(deleteRule: .cascade, inverse: \HoleScore.playerScore)
    var holeScores: [HoleScore] = []
    
    init(player: Player? = nil) {
        self.id = UUID()
        self.player = player
        self.totalGrossScore = 0
        self.totalNetScore = 0
        self.winnings = 0.0
        self.notes = ""
    }
    
    var front9Gross: Int {
        holeScores.filter { $0.holeNumber <= 9 }.reduce(0) { $0 + $1.grossScore }
    }
    
    var back9Gross: Int {
        holeScores.filter { $0.holeNumber > 9 }.reduce(0) { $0 + $1.grossScore }
    }
    
    func strokesReceivedOnHole(_ holeNumber: Int, courseHandicap: Int) -> Int {
        guard let hole = holeScores.first(where: { $0.holeNumber == holeNumber })?.hole else { return 0 }
        
        if courseHandicap >= 18 {
            // Player gets 2 strokes on hardest holes
            let extraStrokes = courseHandicap - 18
            if hole.handicap <= extraStrokes {
                return 2
            }
            return 1
        } else {
            // Player gets 1 stroke on holes up to their handicap
            return hole.handicap <= courseHandicap ? 1 : 0
        }
    }
}
