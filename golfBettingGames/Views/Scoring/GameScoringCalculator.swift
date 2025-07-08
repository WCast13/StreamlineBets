//
//  GameScoringCalculator.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/8/25.
//


import Foundation
import SwiftData

class GameScoringCalculator {
    
    // MARK: - Nassau Scoring
    
    // TODO: - Add support for Press
    static func calculateNassauWinnings(for round: Round) {
        guard round.roundType == .full18 else { return }
        
        let scores = round.scores
        let betAmount = round.betAmount
        
        // Calculate Front 9, Back 9, and Total winners
        let front9Winners = calculateNineHoleWinners(scores: scores, holes: 1...9)
        let back9Winners = calculateNineHoleWinners(scores: scores, holes: 10...18)
        let totalWinners = calculateTotalWinners(scores: scores)
        
        // Reset all winnings
        scores.forEach { $0.winnings = 0 }
        
        // Award winnings for each bet (3 bets total in Nassau)
        awardWinnings(winners: front9Winners, allScores: scores, betAmount: betAmount)
        awardWinnings(winners: back9Winners, allScores: scores, betAmount: betAmount)
        awardWinnings(winners: totalWinners, allScores: scores, betAmount: betAmount)
    }
    
    // MARK: - Match Play Scoring
    
    // TODO: - Add support for teams
    
    static func calculateMatchPlayWinnings(for round: Round) {
        let scores = round.scores
        guard scores.count == 2 else { return } // Match play is typically 1v1
        
        var player1Wins = 0
        var player2Wins = 0
        
        // Count holes won by each player
        for holeNum in 1...18 {
            let p1Score = scores[0].holeScores.first { $0.holeNumber == holeNum }
            let p2Score = scores[1].holeScores.first { $0.holeNumber == holeNum }
            
            if let p1 = p1Score, let p2 = p2Score {
                if p1.netScore < p2.netScore {
                    player1Wins += 1
                } else if p2.netScore < p1.netScore {
                    player2Wins += 1
                }
                // Ties result in no points
            }
        }
        
        // Determine winner
        if player1Wins > player2Wins {
            scores[0].winnings = round.betAmount
            scores[1].winnings = -round.betAmount
        } else if player2Wins > player1Wins {
            scores[0].winnings = -round.betAmount
            scores[1].winnings = round.betAmount
        } else {
            // Tie - no money changes hands
            scores[0].winnings = 0
            scores[1].winnings = 0
        }
    }
    
    // MARK: - Wolf Scoring
    
    // TODO: - Figure out logic
    
    static func calculateWolfWinnings(for round: Round) {
        // Wolf is complex - simplified version
        // The "Wolf" rotates each hole and can choose to play alone or with a partner
        // This would need additional UI to track wolf decisions per hole
        
        // For now, use stroke play as placeholder
        calculateStrokePlayWinnings(for: round)
    }
    
    // MARK: - Best Ball Scoring
    
    // TODO: - Use Match Play Rules
    
    static func calculateBestBallWinnings(for round: Round) {
        // Teams of 2, best score between partners counts
        // This requires team assignments - need to add team support to the model
        
        // For now, use stroke play
        calculateStrokePlayWinnings(for: round)
    }
    
    // MARK: - Stroke Play Scoring
    static func calculateStrokePlayWinnings(for round: Round) {
        let scores = round.scores.sorted { $0.netScore < $1.netScore }
        guard scores.count >= 2 else { return }
        
        let winner = scores[0]
        let totalPot = round.betAmount * Double(scores.count)
        
        // Check for ties
        let lowestScore = winner.netScore
        let winners = scores.filter { $0.netScore == lowestScore }
        
        if winners.count == 1 {
            // Single winner takes all
            winner.winnings = totalPot - round.betAmount
            for score in scores.dropFirst() {
                score.winnings = -round.betAmount
            }
        } else {
            // Split pot among tied players
            let winningsPerPlayer = (totalPot / Double(winners.count)) - round.betAmount
            for score in scores {
                if winners.contains(score) {
                    score.winnings = winningsPerPlayer
                } else {
                    score.winnings = -round.betAmount
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private static func calculateNineHoleWinners(scores: [PlayerScore], holes: ClosedRange<Int>) -> [PlayerScore] {
        var nineHoleTotals: [(score: PlayerScore, total: Int)] = []
        
        for score in scores {
            let total = score.holeScores
                .filter { holes.contains($0.holeNumber) }
                .reduce(0) { $0 + $1.netScore }
            nineHoleTotals.append((score, total))
        }
        
        let lowestTotal = nineHoleTotals.map { $0.total }.min() ?? 0
        return nineHoleTotals
            .filter { $0.total == lowestTotal }
            .map { $0.score }
    }
    
    private static func calculateTotalWinners(scores: [PlayerScore]) -> [PlayerScore] {
        let lowestTotal = scores.map { $0.netScore }.min() ?? 0
        return scores.filter { $0.netScore == lowestTotal }
    }
    
    private static func awardWinnings(winners: [PlayerScore], allScores: [PlayerScore], betAmount: Double) {
        if winners.count == 1 {
            // Single winner
            for score in allScores {
                if winners.contains(score) {
                    score.winnings += betAmount * Double(allScores.count - 1)
                } else {
                    score.winnings -= betAmount
                }
            }
        } else if winners.count > 1 && winners.count < allScores.count {
            // Multiple winners split the pot
            let winningsPerWinner = betAmount * Double(allScores.count - winners.count) / Double(winners.count)
            for score in allScores {
                if winners.contains(score) {
                    score.winnings += winningsPerWinner
                } else {
                    score.winnings -= betAmount
                }
            }
        }
        // If everyone ties, no money changes hands for this bet
    }
}
