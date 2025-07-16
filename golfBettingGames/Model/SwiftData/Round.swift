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
    
    // ADDED: Team scores relationship
    @Relationship(deleteRule: .cascade, inverse: \TeamScore.round)
    var teamScores: [TeamScore] = []
    
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
    
    // ADDED: Helper to get all participants (individual scores and team scores)
    var allParticipants: [Any] {
        var participants: [Any] = []
        
        // Add individual scores not part of a team
        participants.append(contentsOf: scores.filter { $0.teamScore == nil })
        
        // Add team scores
        participants.append(contentsOf: teamScores)
        
        return participants
    }
    
    // ADDED: Check if this is a team round
    var isTeamRound: Bool {
        return !teamScores.isEmpty
    }
    
    // ADDED: Total pot calculation including teams
    var totalPot: Double {
        let individualCount = scores.filter { $0.teamScore == nil }.count
        let teamCount = teamScores.count
        return betAmount * Double(individualCount + teamCount)
    }
}
