//
//  MatchPlayStatus.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/14/25.
//


import SwiftUI
import SwiftData

// MARK: - Match Play Components

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