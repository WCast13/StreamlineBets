//
//  HoleScore.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/26/25.
//

import Foundation
import SwiftData

// MARK: - HoleScore Model
@Model
final class HoleScore {
    var id: UUID
    var holeNumber: Int
    var grossScore: Int
    
    // Relationships
    var playerScore: PlayerScore?
    var hole: Hole?
    
    init(holeNumber: Int, grossScore: Int = 0) {
        self.id = UUID()
        self.holeNumber = holeNumber
        self.grossScore = grossScore
    }
    
    var netScore: Int {
        guard let playerScore = playerScore,
              let player = playerScore.player,
              let round = playerScore.round,
              let game = round.game,
              let hole = hole else { return grossScore }
        
        let courseHandicap = player.courseHandicap(
            courseRating: game.effectiveRating,
            slopeRating: Double(game.effectiveSlope),
            par: game.par
        )
        
        // Calculate strokes on this hole based on handicap
        let strokesOnHole = courseHandicap >= hole.handicap ? 1 : 0
        return grossScore - strokesOnHole
    }
}
