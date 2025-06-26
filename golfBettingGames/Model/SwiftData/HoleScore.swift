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
        // This will be calculated based on strokes received on this hole
        return grossScore // Placeholder - will be updated with proper handicap calculation
    }
}
