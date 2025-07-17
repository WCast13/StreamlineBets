//
//  Round.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/25/25.
//

import SwiftUI
import SwiftData

// MARK: - Updated Round Model
@Model
final class Round {
    var id: UUID
    var roundNumber: Int
    var holeNumber: Int? // For single hole bets
    var startingHole: Int // For tracking which hole they started on (1 or 10)
    var holesPlayed: Int // Number of holes completed
    var date: Date
    var betAmount: Double
    var roundType: RoundType
    var isCompleted: Bool
    
    // Relationships
    var game: Game?
    
    @Relationship(deleteRule: .cascade, inverse: \PlayerScore.round)
    var scores: [PlayerScore] = []
    
    @Relationship var teams: [Team] = []
    
    init(roundNumber: Int, holeNumber: Int? = nil, betAmount: Double, roundType: RoundType, startingHole: Int = 1) {
        self.id = UUID()
        self.roundNumber = roundNumber
        self.holeNumber = holeNumber
        self.date = Date()
        self.betAmount = betAmount
        self.roundType = roundType
        self.isCompleted = false
        self.startingHole = startingHole
        self.holesPlayed = 0
    }
}
