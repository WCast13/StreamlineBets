//
//  GameScoringCalculator.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/8/25.
//

import Foundation
import SwiftData

class GameScoringCalculator {
    
    // MARK: - Real-time Skins Calculation
    static func calculateSkinsForHole(_ holeNumber: Int, in round: Round) -> (winner: Player?, amount: Double, isCarryOver: Bool) {
        let betAmount = round.betAmount
        let scoresForHole = round.scores.compactMap { score in
            (score.player, score.holeScores.first(where: { $0.holeNumber == holeNumber }))
        }
        
        // Check if all players have scored this hole
        guard scoresForHole.count == round.scores.count else {
            return (nil, 0, false)
        }
        
        let validScores = scoresForHole.compactMap { $0.1 }
        let lowestNet = validScores.map { $0.netScore }.min() ?? 0
        let winners = scoresForHole.filter { $0.1?.netScore == lowestNet }
        
        if winners.count == 1, let winner = winners.first?.0 {
            let winAmount = betAmount * Double(round.scores.count - 1)
            return (winner, winAmount, false)
        }
        
        return (nil, 0, true)
    }
    
    // MARK: - Skins Scoring with Carry Over Tracking
    static func calculateSkinsWinnings(for round: Round) {
        let scores = round.scores
        let betAmount = round.betAmount
        var carryOverAmount = 0.0
        
        // Reset all winnings
        scores.forEach { $0.winnings = 0 }
        
        // Process each hole
        let maxHole = scores.flatMap { $0.holeScores }.map { $0.holeNumber }.max() ?? 0
        
        for hole in 1...maxHole {
            let result = calculateSkinsForHole(hole, in: round)
            
            if let winner = result.winner {
                // Find the winner's score object
                if let winnerScore = scores.first(where: { $0.player?.id == winner.id }) {
                    winnerScore.winnings += result.amount + carryOverAmount
                    carryOverAmount = 0.0
                }
                
                // Deduct from losers
                for score in scores where score.player?.id != winner.id {
                    score.winnings -= betAmount
                }
            } else if result.isCarryOver {
                carryOverAmount += betAmount * Double(scores.count)
            }
        }
    }
    
    // MARK: - Nassau Scoring
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
    static func calculateMatchPlayWinnings(for round: Round) {
        let scores = round.scores
        guard scores.count == 2 else { return } // Match play is typically 1v1
        
        var player1Wins = 0
        var player2Wins = 0
        let holesPlayed = scores[0].holeScores.count
        
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
        
        // Check if match is over (player wins by more holes than remain)
        let holesRemaining = 18 - holesPlayed
        let holeDifference = abs(player1Wins - player2Wins)
        
        if holeDifference > holesRemaining || holesPlayed == 18 {
            // Match is complete
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
    }
    
    // MARK: - Wolf Scoring
    static func calculateWolfWinnings(for round: Round) {
        // Wolf is complex - simplified version
        // The "Wolf" rotates each hole and can choose to play alone or with a partner
        // This would need additional UI to track wolf decisions per hole
        
        // For now, use stroke play as placeholder
        calculateStrokePlayWinnings(for: round)
    }
    
    // MARK: - Best Ball Scoring
    static func calculateBestBallWinnings(for round: Round) {
        // In Best Ball, each player plays their own ball but only the best score counts for the team
        // This requires team assignments
        
        guard round.scores.count >= 4 && round.scores.count % 2 == 0 else {
            calculateStrokePlayWinnings(for: round)
            return
        }
        
        // For now, assume first half vs second half
        let team1 = Array(round.scores.prefix(round.scores.count / 2))
        let team2 = Array(round.scores.suffix(round.scores.count / 2))
        
        var team1Score = 0
        var team2Score = 0
        
        // Calculate best ball for each hole
        let maxHole = round.scores.flatMap { $0.holeScores }.map { $0.holeNumber }.max() ?? 0
        
        for hole in 1...maxHole {
            let team1Scores = team1.compactMap { player in
                player.holeScores.first(where: { $0.holeNumber == hole })?.netScore
            }
            let team2Scores = team2.compactMap { player in
                player.holeScores.first(where: { $0.holeNumber == hole })?.netScore
            }
            
            if let bestTeam1 = team1Scores.min(),
               let bestTeam2 = team2Scores.min() {
                team1Score += bestTeam1
                team2Score += bestTeam2
            }
        }
        
        // Award winnings
        if team1Score < team2Score {
            team1.forEach { $0.winnings = round.betAmount }
            team2.forEach { $0.winnings = -round.betAmount }
        } else if team2Score < team1Score {
            team1.forEach { $0.winnings = -round.betAmount }
            team2.forEach { $0.winnings = round.betAmount }
        } else {
            round.scores.forEach { $0.winnings = 0 }
        }
    }
    
    // MARK: - Scramble Scoring
    static func calculateScrambleWinnings(for round: Round) {
        // In scramble, all players hit from the best shot
        // Typically played as team vs field or against another team
        
        // For basic implementation, track the best score per hole
        var teamScore = 0
        let maxHole = round.scores.flatMap { $0.holeScores }.map { $0.holeNumber }.max() ?? 0
        
        for hole in 1...maxHole {
            let holeScores = round.scores.compactMap { player in
                player.holeScores.first(where: { $0.holeNumber == hole })?.grossScore
            }
            
            if let bestScore = holeScores.min() {
                teamScore += bestScore
            }
        }
        
        // For now, equally split any winnings
        let winningsPerPlayer = round.betAmount / Double(round.scores.count)
        round.scores.forEach { $0.winnings = winningsPerPlayer }
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
