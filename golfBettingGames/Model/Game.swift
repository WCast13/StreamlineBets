//
//  Game.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/24/25.
//

import SwiftUI
import SwiftData

// MARK: - Game Model
@Model
final class Game {
    // New Properties for Future Games
    var course: Course?
    var selectedTee: Tee?
    var gender: Gender?
    
    // Helper to get the appropriate rating/slope
    var effectiveRating: Double {
        guard let tee = selectedTee, let gender = gender else {
            return courseRating // fallback to legacy field
        }
        return tee.rating(for: gender)
    }
    
    var effectiveSlope: Int {
        guard let tee = selectedTee, let gender = gender else {
            return Int(slopeRating) // fallback to legacy field
        }
        return tee.slope(for: gender)
    }
    
    // Old Code Supporting Old Games- Will Edit unneeded properties when updating the app functionality
    // TODO: - Delete the course index/rating
    var id: UUID
    var name: String
    var gameType: GameType
    var date: Date
    var courseName: String
    var courseRating: Double
    var slopeRating: Double
    var par: Int
    var isCompleted: Bool
    var notes: String
    
    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \Round.game)
    var rounds: [Round]
    
    var players: [Player]
    
    init(name: String, gameType: GameType, courseName: String, courseRating: Double = 72.0, slopeRating: Double = 113.0, par: Int = 72) {
        self.id = UUID()
        self.name = name
        self.gameType = gameType
        self.date = Date()
        self.courseName = courseName
        self.courseRating = courseRating
        self.slopeRating = slopeRating
        self.par = par
        self.isCompleted = false
        self.notes = ""
        self.rounds = []
        self.players = []
    }
    
    // Calculate total winnings/losses for a player in this game
    func totalForPlayer(_ player: Player) -> Double {
        var total = 0.0
        for round in rounds {
            if let score = round.scores.first(where: { $0.player?.id == player.id }) {
                total += score.winnings
            }
        }
        return total
    }
}
