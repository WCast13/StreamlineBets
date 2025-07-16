//
//  TeamScore.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/16/25.
//


import Foundation
import SwiftData

// MARK: - TeamScore Model
@Model
final class TeamScore {
    var id: UUID
    var score: Int // Total gross score
    var netScore: Int // Total net score
    var winnings: Double
    var notes: String
    var scoringType: TeamScoringType // How the team score is calculated
    
    // Relationships
    var team: Team?
    var round: Round?
    
    // Individual player scores for this team (for tracking individual contributions)
    @Relationship(deleteRule: .cascade, inverse: \PlayerScore.teamScore)
    var playerScores: [PlayerScore] = []
    
    init(team: Team? = nil, score: Int = 0, netScore: Int = 0, winnings: Double = 0.0, scoringType: TeamScoringType = .bestBall) {
        self.id = UUID()
        self.team = team
        self.score = score
        self.netScore = netScore
        self.winnings = winnings
        self.notes = ""
        self.scoringType = scoringType
    }
    
    // Update team scores based on scoring type and player scores
    func updateTeamScores() {
        guard !playerScores.isEmpty else {
            score = 0
            netScore = 0
            return
        }
        
        switch scoringType {
        case .bestBall:
            calculateBestBallScore()
        case .scramble:
            calculateScrambleScore()
        case .aggregate:
            calculateAggregateScore()
        case .alternate:
            calculateAlternateScore()
        }
    }
    
    private func calculateBestBallScore() {
        // Best ball: Take the best score on each hole
        var totalGross = 0
        var totalNet = 0
        
        // Get all unique hole numbers
        let holeNumbers = Set(playerScores.flatMap { $0.holeScores.map { $0.holeNumber } })
        
        for holeNumber in holeNumbers {
            let holeScores = playerScores.compactMap { playerScore in
                playerScore.holeScores.first(where: { $0.holeNumber == holeNumber })
            }
            
            if let bestGross = holeScores.map({ $0.grossScore }).min() {
                totalGross += bestGross
            }
            
            if let bestNet = holeScores.map({ $0.netScore }).min() {
                totalNet += bestNet
            }
        }
        
        score = totalGross
        netScore = totalNet
    }
    
    private func calculateScrambleScore() {
        // Scramble: Usually tracked separately as team plays from best shot
        // For now, use best ball calculation as placeholder
        calculateBestBallScore()
    }
    
    private func calculateAggregateScore() {
        // Aggregate: Sum of all player scores
        score = playerScores.reduce(0) { $0 + $1.score }
        netScore = playerScores.reduce(0) { $0 + $1.netScore }
    }
    
    private func calculateAlternateScore() {
        // Alternate shot: Players alternate shots, so score is tracked differently
        // For now, use the first player's score as the team score
        if let firstPlayer = playerScores.first {
            score = firstPlayer.score
            netScore = firstPlayer.netScore
        }
    }
    
    var front9Score: Int {
        switch scoringType {
        case .bestBall, .scramble:
            var total = 0
            for hole in 1...9 {
                let holeScores = playerScores.compactMap { playerScore in
                    playerScore.holeScores.first(where: { $0.holeNumber == hole })?.grossScore
                }
                if let best = holeScores.min() {
                    total += best
                }
            }
            return total
        case .aggregate:
            return playerScores.reduce(0) { $0 + $1.front9Score }
        case .alternate:
            return playerScores.first?.front9Score ?? 0
        }
    }
    
    var back9Score: Int {
        switch scoringType {
        case .bestBall, .scramble:
            var total = 0
            for hole in 10...18 {
                let holeScores = playerScores.compactMap { playerScore in
                    playerScore.holeScores.first(where: { $0.holeNumber == hole })?.grossScore
                }
                if let best = holeScores.min() {
                    total += best
                }
            }
            return total
        case .aggregate:
            return playerScores.reduce(0) { $0 + $1.back9Score }
        case .alternate:
            return playerScores.first?.back9Score ?? 0
        }
    }
}

// MARK: - Team Scoring Type Enum
enum TeamScoringType: String, Codable, CaseIterable {
    case bestBall = "Best Ball"
    case scramble = "Scramble"
    case aggregate = "Aggregate"
    case alternate = "Alternate Shot"
    
    var description: String {
        return self.rawValue
    }
}
