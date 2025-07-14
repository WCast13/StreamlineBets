//
//  MatchPlayHoleResult 2.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/14/25.
//

import SwiftUI
import SwiftData

struct MatchPlayHoleResult: View {
    let holeNumber: Int
    let round: Round
    let isCurrentHole: Bool
    
    private var holeWinner: MatchPlayResult {
        guard round.scores.count == 2,
              let player1Score = round.scores[0].holeScores.first(where: { $0.holeNumber == holeNumber }),
              let player2Score = round.scores[1].holeScores.first(where: { $0.holeNumber == holeNumber }) else {
            return .notPlayed
        }
        
        if player1Score.netScore < player2Score.netScore {
            return .player1Won
        } else if player2Score.netScore < player1Score.netScore {
            return .player2Won
        } else {
            return .halved
        }
    }
    
    enum MatchPlayResult {
        case player1Won
        case player2Won
        case halved
        case notPlayed
    }
    
    var body: some View {
        ZStack {
            switch holeWinner {
            case .player1Won:
                Circle()
                    .fill(Color.blue)
                    .frame(width: 14, height: 14)
                    .overlay(
                        Text("1")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundColor(.white)
                    )
            case .player2Won:
                Circle()
                    .fill(Color.red)
                    .frame(width: 14, height: 14)
                    .overlay(
                        Text("2")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundColor(.white)
                    )
            case .halved:
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Text("H")
                            .font(.system(size: 6, weight: .bold))
                            .foregroundColor(.white)
                    )
            case .notPlayed:
                if isCurrentHole {
                    Circle()
                        .stroke(Color.accentColor, lineWidth: 2)
                        .frame(width: 14, height: 14)
                } else {
                    Text("-")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(width: 24, height: 14)
    }
}
