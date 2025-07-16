//
//  MatchPlayDetailedView.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/14/25.
//

import SwiftUI
import SwiftData

// MARK: - Match Play Detailed View

//struct MatchPlayDetailedView: View {
//    let round: Round
//    let currentHoleNumber: Int
//    
//    private var player1Name: String {
//        round.scores.first?.player?.name ?? "Player 1"
//    }
//    
//    private var player2Name: String {
//        round.scores.count > 1 ? (round.scores[1].player?.name ?? "Player 2") : "Player 2"
//    }
//    
//    private func getMatchStatusAfterHole(_ hole: Int) -> (player1Up: Int, player2Up: Int) {
//        guard round.scores.count == 2 else { return (0, 0) }
//        
//        var p1Wins = 0
//        var p2Wins = 0
//        
//        for h in 1...hole {
//            if let score1 = round.scores[0].holeScores.first(where: { $0.holeNumber == h }),
//               let score2 = round.scores[1].holeScores.first(where: { $0.holeNumber == h }) {
//                if score1.netScore < score2.netScore {
//                    p1Wins += 1
//                } else if score2.netScore < score1.netScore {
//                    p2Wins += 1
//                }
//            }
//        }
//        
//        return (p1Wins - p2Wins, p2Wins - p1Wins)
//    }
//    
//    var body: some View {
//        VStack(spacing: 4) {
//            // Player Names Header
//            HStack(spacing: 0) {
//                Text("Players")
//                    .frame(width: 60, height: 16, alignment: .leading)
//                    .font(.system(size: 8, weight: .semibold))
//                    .padding(.horizontal, 4)
//                
//                Spacer()
//                
//                HStack(spacing: 16) {
//                    HStack(spacing: 4) {
//                        Circle()
//                            .fill(Color.blue)
//                            .frame(width: 10, height: 10)
//                        Text(player1Name)
//                            .font(.system(size: 8, weight: .medium))
//                            .lineLimit(1)
//                    }
//                    
//                    Text("vs")
//                        .font(.system(size: 8))
//                        .foregroundColor(.secondary)
//                    
//                    HStack(spacing: 4) {
//                        Circle()
//                            .fill(Color.red)
//                            .frame(width: 10, height: 10)
//                        Text(player2Name)
//                            .font(.system(size: 8, weight: .medium))
//                            .lineLimit(1)
//                    }
//                }
//                .frame(maxWidth: .infinity)
//                
//                Spacer()
//            }
//            .padding(.vertical, 4)
//            
//            // Hole-by-hole match status
//            HStack(spacing: 0) {
//                Text("STATUS")
//                    .frame(width: 60, height: 14, alignment: .leading)
//                    .font(.system(size: 8, weight: .semibold))
//                    .padding(.horizontal, 4)
//                    .foregroundColor(.secondary)
//                
//                // Front 9
//                ForEach(1...9, id: \.self) { hole in
//                    MatchStatusCell(
//                        hole: hole,
//                        matchStatus: getMatchStatusAfterHole(hole),
//                        isCurrentHole: currentHoleNumber == hole,
//                        hasScore: hasScoreForHole(hole)
//                    )
//                }
//                
//                Text("")
//                    .frame(width: 32, height: 14)
//                
//                Divider()
//                    .frame(width: 1, height: 10)
//                    .padding(.horizontal, 2)
//                
//                // Back 9
//                ForEach(10...18, id: \.self) { hole in
//                    MatchStatusCell(
//                        hole: hole,
//                        matchStatus: getMatchStatusAfterHole(hole),
//                        isCurrentHole: currentHoleNumber == hole,
//                        hasScore: hasScoreForHole(hole)
//                    )
//                }
//                
//                Text("")
//                    .frame(width: 64, height: 14)
//            }
//            .padding(.vertical, 2)
//            
//            Divider()
//                .frame(height: 0.5)
//        }
//    }
//    
//    private func hasScoreForHole(_ hole: Int) -> Bool {
//        guard round.scores.count == 2 else { return false }
//        return round.scores[0].holeScores.contains(where: { $0.holeNumber == hole }) &&
//               round.scores[1].holeScores.contains(where: { $0.holeNumber == hole })
//    }
//}
