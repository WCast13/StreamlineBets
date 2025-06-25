//
//  Player.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/24/25.
//

import SwiftUI
import SwiftData

// MARK: - Player Model
@Model
final class Player {
    var id: UUID
    var name: String
    var handicapIndex: Double
    var createdDate: Date
    var isActive: Bool
    
    //Relationships
    @Relationship(deleteRule: .cascade, inverse: \PlayerScore.player)
    var scores: [PlayerScore]
    
    @Relationship(inverse: \Game.players)
    var games: [Game]
    
    init(name: String, handicapIndex: Double = 0.0) {
        self.id = UUID()
        self.name = name
        self.handicapIndex = handicapIndex
        self.createdDate = Date()
        self.isActive = true
        self.scores = []
        self.games = []
    }
    
    // Calculate course handicap based on course rating and slope
    func courseHandicap(courseRating: Double, slopeRating: Double, par: Int) -> Int {
        let courseHandicap = (handicapIndex * slopeRating / 113) + (courseRating - Double(par))
        return Int(round(courseHandicap))
    }
}
