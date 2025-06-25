//
//  PlayerScore.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/25/25.
//


import Foundation
import SwiftData


// MARK: - PlayerScore Model
@Model
final class PlayerScore {
    var id: UUID
    var score: Int
    var netScore: Int
    var winnings: Double
    var notes: String
    
    // Relationships
    var player: Player?
    var round: Round?
    
    init(player: Player? = nil, score: Int = 0, netScore: Int = 0, winnings: Double = 0.0) {
        self.id = UUID()
        self.player = player
        self.score = score
        self.netScore = netScore
        self.winnings = winnings
        self.notes = ""
    }
}
