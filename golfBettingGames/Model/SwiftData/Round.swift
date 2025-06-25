//
//  Round.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/25/25.
//

import SwiftUI
import SwiftData

// MARK: - Round Model
@Model
final class Round {
    var id: UUID
    var roundNumber: Int
    var holeNumber: Int?
    var date: Date
    var betAmount: Double
    var roundType: RoundType
    var isCompleted: Bool
    
    // Relationships
    var game: Game?
    
    @Relationship(deleteRule: .cascade, inverse: \PlayerScore.round)
    var scores: [PlayerScore] = []
    
    init(roundNumber: Int, holeNumber: Int? = nil, betAmount: Double, roundType: RoundType) {
        self.id = UUID()
        self.roundNumber = roundNumber
        self.holeNumber = holeNumber
        self.date = Date()
        self.betAmount = betAmount
        self.roundType = roundType
        self.isCompleted = false
    }
}
