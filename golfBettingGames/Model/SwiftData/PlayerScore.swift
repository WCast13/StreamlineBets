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
    var score: Int // Total gross score
    var netScore: Int // Total net score
    var winnings: Double
    var notes: String
    
    // Relationships
    var player: Player?
    var round: Round?
    var teamScore: TeamScore?
    
    @Relationship(deleteRule: .cascade, inverse: \HoleScore.playerScore)
    var holeScores: [HoleScore] = []
    
    init(player: Player? = nil, score: Int = 0, netScore: Int = 0, winnings: Double = 0.0) {
        self.id = UUID()
        self.player = player
        self.score = score
        self.netScore = netScore
        self.winnings = winnings
        self.notes = ""
    }
    
    func updateTotalScores() {
        score = holeScores.reduce(0) { $0 + $1.grossScore }
        netScore = holeScores.reduce(0) { $0 + $1.netScore }
        
        teamScore?.updateTeamScores()
    }
    
    var front9Score: Int {
        holeScores.filter { $0.holeNumber <= 9 }
            .reduce(0) { $0 + $1.grossScore }
    }
    
    var back9Score: Int {
        holeScores.filter { $0.holeNumber > 9 }
            .reduce(0) { $0 + $1.grossScore }
    }
}
