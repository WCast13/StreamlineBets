//
//  Game.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/24/25.
//

import Foundation
import SwiftData

// MARK: - Game Model
@Model
final class Game {
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
    
    // ADDED: Game format (individual vs team)
    var gameFormat: GameFormat
    
    // New properties for course integration
    var course: Course?
    var selectedTee: Tee?
    var selectedGender: Gender?
    
    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \Round.game)
    var rounds: [Round] = []
    
    @Relationship var players: [Player] = []
    
    // ADDED: Team relationships
    @Relationship var teams: [Team] = []
    
    init(name: String, gameType: GameType, courseName: String, courseRating: Double = 72.0, slopeRating: Double = 113.0, par: Int = 72, gameFormat: GameFormat = .individual) {
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
        self.gameFormat = gameFormat
    }
    
    // Helper to get the appropriate rating/slope
    var effectiveRating: Double {
        guard let tee = selectedTee, let gender = selectedGender else {
            return courseRating
        }
        return tee.rating(for: gender)
    }
    
    var effectiveSlope: Int {
        guard let tee = selectedTee, let gender = selectedGender else {
            return Int(slopeRating)
        }
        return tee.slope(for: gender)
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
    
    // ADDED: Calculate total winnings/losses for a team in this game
    func totalForTeam(_ team: Team) -> Double {
        var total = 0.0
        for round in rounds {
            if let teamScore = round.teamScores.first(where: { $0.team?.id == team.id }) {
                total += teamScore.winnings
            }
        }
        return total
    }
    
    // ADDED: Get all participants (players and/or teams)
    var allParticipants: [Any] {
        switch gameFormat {
        case .individual:
            return players
        case .team:
            return teams
        case .mixed:
            return players + teams
        }
    }
}

// MARK: - Game Format Enum
enum GameFormat: String, Codable, CaseIterable {
    case individual = "Individual"
    case team = "Team"
    case mixed = "Mixed" // Both individuals and teams
    
    var description: String {
        return self.rawValue
    }
}
