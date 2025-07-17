//
//  MatchPlayComponets.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/14/25.
//

// Views/Scoring/Scorecard/Components/MatchPlayComponents.swift
import SwiftUI
import SwiftData

// MARK: - Match Play Status Component
struct MatchPlayStatus: View {
    let round: Round
    
    private var matchStatus: (status: String, color: Color) {
        guard round.scores.count == 2 else {
            return ("--", .gray)
        }
        
        var player1Holes = 0
        var player2Holes = 0
        
        for score1 in round.scores[0].holeScores {
            if let score2 = round.scores[1].holeScores.first(where: { $0.holeNumber == score1.holeNumber }) {
                if score1.netScore < score2.netScore {
                    player1Holes += 1
                } else if score2.netScore < score1.netScore {
                    player2Holes += 1
                }
            }
        }
        
        let holesPlayed = round.scores[0].holeScores.count
        let holesRemaining = 18 - holesPlayed
        
        if player1Holes > player2Holes {
            let up = player1Holes - player2Holes
            if up > holesRemaining {
                return ("\(up)&\(holesRemaining)", .blue)
            }
            return ("\(up)UP", .blue)
        } else if player2Holes > player1Holes {
            let up = player2Holes - player1Holes
            if up > holesRemaining {
                return ("\(up)&\(holesRemaining)", .red)
            }
            return ("\(up)UP", .red)
        }
        
        return ("AS", .orange)
    }
    
    var body: some View {
        Text(matchStatus.status)
            .font(.system(size: 7, weight: .bold))
            .foregroundColor(matchStatus.color)
    }
}

// MARK: - Match Play Player Row
struct MatchPlayPlayerRow: View {
    let playerScore: PlayerScore
    let opponentScore: PlayerScore
    let playerNumber: Int
    let currentHoleNumber: Int?
    let front9Holes: [Hole]
    let back9Holes: [Hole]
    
    private var playerName: String {
        if let name = playerScore.player?.name {
            return String(name.prefix(8))
        }
        return "Player \(playerNumber)"
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Text(playerName)
                .frame(width: 60, alignment: .leading)
                .font(.system(size: 8, weight: .medium))
                .padding(.horizontal, 4)
                .lineLimit(1)
            
            // Front 9 match play status per hole
            ForEach(1...9, id: \.self) { holeNum in
                MatchPlayCellStatus(
                    playerScore: playerScore,
                    opponentScore: opponentScore,
                    holeNumber: holeNum,
                    isCurrentHole: currentHoleNumber == holeNum
                )
            }
            
            Text("")
                .frame(width: 36)
            
            Divider()
                .frame(width: 1, height: 10)
                .padding(.horizontal, 2)
            
            // Back 9 match play status per hole
            ForEach(10...18, id: \.self) { holeNum in
                MatchPlayCellStatus(
                    playerScore: playerScore,
                    opponentScore: opponentScore,
                    holeNumber: holeNum,
                    isCurrentHole: currentHoleNumber == holeNum
                )
            }
            
            Text("")
                .frame(width: 36)
            
            // Total match status
            MatchPlayTotalStatus(
                playerScore: playerScore,
                opponentScore: opponentScore
            )
            .frame(width: 36)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Match Play Cell Result
struct MatchPlayCellResult: View {
    let playerScore: PlayerScore
    let opponentScore: PlayerScore
    let holeNumber: Int
    let isCurrentHole: Bool
    
    private var result: (text: String, color: Color) {
        // Check if this hole has been played
        guard let playerHole = playerScore.holeScores.first(where: { $0.holeNumber == holeNumber }),
              let opponentHole = opponentScore.holeScores.first(where: { $0.holeNumber == holeNumber }) else {
            return ("-", .secondary)
        }
        
        // Simple hole result
        if playerHole.netScore < opponentHole.netScore {
            return ("W", .primary)  // Won hole
        } else if playerHole.netScore > opponentHole.netScore {
            return ("L", .primary)    // Lost hole
        } else {
            return ("H", .primary) // Halved hole
        }
    }
    
    var body: some View {
        Text(result.text)
            .frame(width: 28)
            .font(.system(size: 8, weight: isCurrentHole ? .bold : .medium))
            .foregroundColor(result.color)
            .background(
                isCurrentHole ?
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.accentColor.opacity(0.15))
                    .padding(.horizontal, 1) : nil
            )
    }
}

// MARK: - MatchPlayCellStatus (new)
struct MatchPlayCellStatus: View {
    let playerScore: PlayerScore
    let opponentScore: PlayerScore
    let holeNumber: Int
    let isCurrentHole: Bool

    private var matchStatus: (text: String, color: Color) {
        var wins = 0
        var losses = 0
        for h in 1...holeNumber {
            if let playerHole = playerScore.holeScores.first(where: { $0.holeNumber == h }),
               let opponentHole = opponentScore.holeScores.first(where: { $0.holeNumber == h }) {
                if playerHole.netScore < opponentHole.netScore {
                    wins += 1
                } else if playerHole.netScore > opponentHole.netScore {
                    losses += 1
                }
            }
        }
        if wins > losses {
            return ("\(wins - losses) UP", .primary)
        } else if losses > wins {
            return ("", .primary)
        } else {
            return ("AS", .primary)
        }
    }

    var body: some View {
        Text(matchStatus.text)
            .frame(width: 28)
            .font(.system(size: 8, weight: isCurrentHole ? .bold : .medium))
            .foregroundColor(matchStatus.color)
            .background(
                isCurrentHole ?
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.accentColor.opacity(0.15))
                    .padding(.horizontal, 1) : nil
            )
    }
}

// MARK: - Match Play Total Status
struct MatchPlayTotalStatus: View {
    let playerScore: PlayerScore
    let opponentScore: PlayerScore
    
    private var totalStatus: (text: String, color: Color) {
        var wins = 0
        var losses = 0
        
        for hole in playerScore.holeScores {
            if let opponentHole = opponentScore.holeScores.first(where: { $0.holeNumber == hole.holeNumber }) {
                if hole.netScore < opponentHole.netScore {
                    wins += 1
                } else if hole.netScore > opponentHole.netScore {
                    losses += 1
                }
            }
        }
        
        if wins > losses {
            return ("+\(wins - losses)", .green)
        } else if losses > wins {
            return ("-\(losses - wins)", .red)
        } else {
            return ("AS", .orange)
        }
    }
    
    var body: some View {
        Text(totalStatus.text)
            .font(.system(size: 8, weight: .bold))
            .foregroundColor(totalStatus.color)
    }
}

// MARK: - Match Status Cell
struct MatchStatusCell: View {
    let hole: Int
    let matchStatus: (player1Up: Int, player2Up: Int)
    let isCurrentHole: Bool
    let hasScore: Bool
    
    private var statusText: String {
        if !hasScore { return "-" }
        
        if matchStatus.player1Up > 0 {
            return "\(matchStatus.player1Up)"
        } else if matchStatus.player2Up > 0 {
            return "\(matchStatus.player2Up)"
        } else {
            return "AS"
        }
    }
    
    private var statusColor: Color {
        if !hasScore { return .secondary }
        
        if matchStatus.player1Up > 0 {
            return .blue
        } else if matchStatus.player2Up > 0 {
            return .red
        } else {
            return .orange
        }
    }
    
    var body: some View {
        Text(statusText)
            .frame(width: 24, height: 14)
            .font(.system(size: 7, weight: isCurrentHole ? .bold : .medium))
            .foregroundColor(statusColor)
            .background(
                isCurrentHole ?
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.accentColor.opacity(0.15))
                    .padding(.horizontal, 1) : nil
            )
    }
}

// MARK: - Match Play Detailed View
struct MatchPlayDetailedView: View {
    let round: Round
    let currentHoleNumber: Int
    
    private var player1Name: String {
        round.scores.first?.player?.name ?? "Player 1"
    }
    
    private var player2Name: String {
        round.scores.count > 1 ? (round.scores[1].player?.name ?? "Player 2") : "Player 2"
    }
    
    private func getMatchStatusAfterHole(_ hole: Int) -> (player1Up: Int, player2Up: Int) {
        guard round.scores.count == 2 else { return (0, 0) }
        
        var p1Wins = 0
        var p2Wins = 0
        
        for h in 1...hole {
            if let score1 = round.scores[0].holeScores.first(where: { $0.holeNumber == h }),
               let score2 = round.scores[1].holeScores.first(where: { $0.holeNumber == h }) {
                if score1.netScore < score2.netScore {
                    p1Wins += 1
                } else if score2.netScore < score1.netScore {
                    p2Wins += 1
                }
            }
        }
        
        return (p1Wins - p2Wins, p2Wins - p1Wins)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            // Player Names Header
            HStack(spacing: 0) {
                Text("Players")
                    .frame(width: 60, height: 16, alignment: .leading)
                    .font(.system(size: 8, weight: .semibold))
                    .padding(.horizontal, 4)
                
                Spacer()
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 10, height: 10)
                        Text(player1Name)
                            .font(.system(size: 8, weight: .medium))
                            .lineLimit(1)
                    }
                    
                    Text("vs")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                        Text(player2Name)
                            .font(.system(size: 8, weight: .medium))
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
            }
            .padding(.vertical, 4)
            
            // Match Status Key
            HStack(spacing: 20) {
                Label("W = Won", systemImage: "")
                    .font(.system(size: 7))
                    .foregroundColor(.green)
                
                Label("L = Lost", systemImage: "")
                    .font(.system(size: 7))
                    .foregroundColor(.red)
                
                Label("H = Halved", systemImage: "")
                    .font(.system(size: 7))
                    .foregroundColor(.orange)
                
                Label("AS = All Square", systemImage: "")
                    .font(.system(size: 7))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 6)
        }
    }
    
    private func hasScoreForHole(_ hole: Int) -> Bool {
        guard round.scores.count == 2 else { return false }
        return round.scores[0].holeScores.contains(where: { $0.holeNumber == hole }) &&
               round.scores[1].holeScores.contains(where: { $0.holeNumber == hole })
    }
}

