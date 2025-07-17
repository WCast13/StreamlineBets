//
//  GameScoringCalculator+Nassau.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/17/25.
//

import Foundation
import SwiftData

// MARK: - Nassau Scoring Extension
extension GameScoringCalculator {
    
    // MARK: - Nassau Scoring Calculation
    static func calculateNassauWinnings(for round: Round) {
        guard round.scores.count >= 2 else { return }
        
        let scores = round.scores
        let betAmount = round.betAmount
        
        // Reset all winnings
        scores.forEach { $0.winnings = 0 }
        
        // For team Nassau, we need to handle teams
        if round.scores.count > 2 {
            calculateTeamNassauWinnings(for: round)
            return
        }
        
        // Standard 2-player Nassau
        let front9Status = NassauCalculator.calculateBetStatus(for: 1...9, in: round)
        let back9Status = NassauCalculator.calculateBetStatus(for: 10...18, in: round)
        let overallStatus = NassauCalculator.calculateBetStatus(for: 1...18, in: round)
        
        // Award winnings for each bet
        awardNassauBet(status: front9Status, scores: scores, betAmount: betAmount)
        awardNassauBet(status: back9Status, scores: scores, betAmount: betAmount)
        awardNassauBet(status: overallStatus, scores: scores, betAmount: betAmount)
        
        // Handle presses
        let presses = NassauCalculator.findActivePresses(in: round)
        for press in presses {
            awardNassauBet(status: press.status, scores: scores, betAmount: betAmount)
        }
    }
    
    private static func awardNassauBet(status: NassauBetStatus, scores: [PlayerScore], betAmount: Double) {
        guard scores.count >= 2 else { return }
        
        switch status.leader {
        case .player1:
            scores[0].winnings += betAmount
            scores[1].winnings -= betAmount
        case .player2:
            scores[0].winnings -= betAmount
            scores[1].winnings += betAmount
        case .tied, .notStarted:
            // No money changes hands
            break
        }
    }
    
    // MARK: - Team Nassau Calculation
    private static func calculateTeamNassauWinnings(for round: Round) {
        // For team Nassau, divide players into two teams
        // This is a simplified version - in a real app, team assignments would be stored
        let scores = round.scores
        let betAmount = round.betAmount
        
        guard scores.count >= 4 && scores.count % 2 == 0 else {
            // Fall back to stroke play if not enough players for teams
            calculateStrokePlayWinnings(for: round)
            return
        }
        
        // Divide into teams
        let team1 = Array(scores.prefix(scores.count / 2))
        let team2 = Array(scores.suffix(scores.count / 2))
        
        // Calculate team Nassau results
        let front9Result = calculateTeamNassauResult(team1: team1, team2: team2, holes: 1...9)
        let back9Result = calculateTeamNassauResult(team1: team1, team2: team2, holes: 10...18)
        let overallResult = calculateTeamNassauResult(team1: team1, team2: team2, holes: 1...18)
        
        // Award winnings
        let betPerPlayer = betAmount / Double(scores.count / 2)
        
        // Front 9
        awardTeamNassauWinnings(result: front9Result, team1: team1, team2: team2, betPerPlayer: betPerPlayer)
        
        // Back 9
        awardTeamNassauWinnings(result: back9Result, team1: team1, team2: team2, betPerPlayer: betPerPlayer)
        
        // Overall
        awardTeamNassauWinnings(result: overallResult, team1: team1, team2: team2, betPerPlayer: betPerPlayer)
    }
    
    private static func calculateTeamNassauResult(team1: [PlayerScore], team2: [PlayerScore], holes: ClosedRange<Int>) -> TeamNassauResult {
        var team1Holes = 0
        var team2Holes = 0
        
        for hole in holes {
            // Get best ball for each team
            let team1Best = team1.compactMap { score in
                score.holeScores.first(where: { $0.holeNumber == hole })?.netScore
            }.min()
            
            let team2Best = team2.compactMap { score in
                score.holeScores.first(where: { $0.holeNumber == hole })?.netScore
            }.min()
            
            if let t1 = team1Best, let t2 = team2Best {
                if t1 < t2 {
                    team1Holes += 1
                } else if t2 < t1 {
                    team2Holes += 1
                }
                // Ties result in no holes won
            }
        }
        
        if team1Holes > team2Holes {
            return .team1Won(holesUp: team1Holes - team2Holes)
        } else if team2Holes > team1Holes {
            return .team2Won(holesUp: team2Holes - team1Holes)
        } else {
            return .tied
        }
    }
    
    private static func awardTeamNassauWinnings(result: TeamNassauResult, team1: [PlayerScore], team2: [PlayerScore], betPerPlayer: Double) {
        switch result {
        case .team1Won:
            team1.forEach { $0.winnings += betPerPlayer }
            team2.forEach { $0.winnings -= betPerPlayer }
        case .team2Won:
            team1.forEach { $0.winnings -= betPerPlayer }
            team2.forEach { $0.winnings += betPerPlayer }
        case .tied:
            // No money changes hands
            break
        }
    }
    
    // MARK: - Helper Types
    private enum TeamNassauResult {
        case team1Won(holesUp: Int)
        case team2Won(holesUp: Int)
        case tied
    }
}

// MARK: - Press Management Extension
extension Round {
    // In a real app, these would be stored properties
    var nassauPresses: [NassauPress] {
        get {
            // For now, calculate dynamically
            return NassauCalculator.findActivePresses(in: self)
        }
    }
    
    func addNassauPress(startingHole: Int) {
        // In a real implementation, this would add a press to the model
        // For now, this is a placeholder
    }
    
    func canInitiatePress(for holes: ClosedRange<Int>) -> Bool {
        guard scores.count == 2 else { return false }
        
        let status = NassauCalculator.calculateBetStatus(for: holes, in: self)
        
        // Can press if down by 2 or more holes
        return status.holesUp >= 2 && !status.isComplete
    }
}
