//
//  GameStatusService.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/14/25.
//

import Foundation
import SwiftData
import SwiftUI

struct GameStatusService {
    
    // MARK: - Match Play Status
    struct MatchPlayStatus {
        let leader: Player?
        let holesUp: Int
        let holesRemaining: Int
        let isComplete: Bool
        
        var statusText: String {
            guard let leader = leader else { return "All Square" }
            
            if isComplete {
                if holesUp > holesRemaining {
                    return "\(leader.name) wins \(holesUp) & \(holesRemaining)"
                } else {
                    return "\(leader.name) wins"
                }
            } else {
                return holesUp > 0 ? "\(leader.name) \(holesUp) UP" : "All Square"
            }
        }
        
        var statusColor: Color {
            holesUp > 0 ? .green : .orange
        }
    }
    
    static func getMatchPlayStatus(for round: Round) -> MatchPlayStatus? {
        guard round.scores.count == 2,
              let player1 = round.scores[0].player,
              let player2 = round.scores[1].player else { return nil }
        
        var player1Wins = 0
        var player2Wins = 0
        
        for holeScore in round.scores[0].holeScores {
            if let opponentScore = round.scores[1].holeScores.first(where: { $0.holeNumber == holeScore.holeNumber }) {
                if holeScore.netScore < opponentScore.netScore {
                    player1Wins += 1
                } else if holeScore.netScore > opponentScore.netScore {
                    player2Wins += 1
                }
            }
        }
        
        let holesPlayed = round.scores[0].holeScores.count
        let holesRemaining = 18 - holesPlayed
        let difference = abs(player1Wins - player2Wins)
        
        if player1Wins > player2Wins {
            return MatchPlayStatus(
                leader: player1,
                holesUp: difference,
                holesRemaining: holesRemaining,
                isComplete: difference > holesRemaining || holesPlayed == 18
            )
        } else if player2Wins > player1Wins {
            return MatchPlayStatus(
                leader: player2,
                holesUp: difference,
                holesRemaining: holesRemaining,
                isComplete: difference > holesRemaining || holesPlayed == 18
            )
        } else {
            return MatchPlayStatus(
                leader: nil,
                holesUp: 0,
                holesRemaining: holesRemaining,
                isComplete: holesPlayed == 18
            )
        }
    }
    
    // MARK: - Skins Status
    struct SkinsStatus {
        let playerWinnings: [(player: Player, amount: Double, holesWon: Int)]
        let carryOverHoles: Int
        let totalPot: Double
    }
    
    static func getSkinsStatus(for round: Round) -> SkinsStatus {
        var winnings: [Player: (amount: Double, holes: Int)] = [:]
        var carryOvers = 0
        let betAmount = round.betAmount
        let totalPot = betAmount * Double(round.scores.count)
        
        let maxHole = round.scores.flatMap { $0.holeScores }.map { $0.holeNumber }.max() ?? 0
        
        for hole in 1...maxHole {
            let result = GameScoringCalculator.calculateSkinsForHole(hole, in: round)
            
            if let winner = result.winner {
                let current = winnings[winner] ?? (0, 0)
                winnings[winner] = (current.0 + result.amount, current.1 + 1)
            } else if result.isCarryOver {
                carryOvers += 1
            }
        }
        
        let playerWinnings = winnings.map { (player: $0.key, amount: $0.value.0, holesWon: $0.value.1) }
            .sorted { $0.amount > $1.amount }
        
        return SkinsStatus(
            playerWinnings: playerWinnings,
            carryOverHoles: carryOvers,
            totalPot: totalPot
        )
    }
    
    // MARK: - Leaderboard
    struct LeaderboardEntry {
        let player: Player
        let grossScore: Int
        let netScore: Int
        let holesCompleted: Int
        let position: Int
        
        var thruText: String {
            holesCompleted > 0 ? "(\(holesCompleted))" : ""
        }
    }
    
    static func getLeaderboard(for round: Round) -> [LeaderboardEntry] {
        let entries = round.scores.compactMap { score -> (player: Player, gross: Int, net: Int, holes: Int)? in
            guard let player = score.player else { return nil }
            return (player, score.score, score.netScore, score.holeScores.count)
        }
        
        let sorted = entries.sorted { $0.net < $1.net }
        
        return sorted.enumerated().map { index, entry in
            LeaderboardEntry(
                player: entry.player,
                grossScore: entry.gross,
                netScore: entry.net,
                holesCompleted: entry.holes,
                position: index + 1
            )
        }
    }
    
    // MARK: - Round Progress
    struct RoundProgress {
        let holesCompleted: Int
        let totalHoles: Int
        let percentComplete: Double
        let isComplete: Bool
        
        var progressText: String {
            "\(holesCompleted) of \(totalHoles) holes"
        }
    }
    
    static func getRoundProgress(for round: Round) -> RoundProgress {
        let holesCompleted = round.scores.first?.holeScores.count ?? 0
        let totalHoles: Int
        
        switch round.roundType {
        case .hole: totalHoles = 1
        case .front9, .back9: totalHoles = 9
        case .full18: totalHoles = 18
        case .custom: totalHoles = round.holesPlayed
        }
        
        let percentComplete = totalHoles > 0 ? Double(holesCompleted) / Double(totalHoles) : 0
        
        return RoundProgress(
            holesCompleted: holesCompleted,
            totalHoles: totalHoles,
            percentComplete: percentComplete,
            isComplete: holesCompleted >= totalHoles
        )
    }
}
