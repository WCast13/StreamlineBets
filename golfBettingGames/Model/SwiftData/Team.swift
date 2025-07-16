//
//  Team.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/16/25.
//

import SwiftUI
import SwiftData

// MARK: - Team Model
@Model
final class Team {
    var id: UUID
    var name: String
    var createdDate: Date
    var isActive: Bool
    
    // Relationships
    @Relationship(deleteRule: .nullify)
    var players: [Player] = []
    
    @Relationship(deleteRule: .cascade, inverse: \TeamScore.team)
    var teamScores: [TeamScore] = []
    
    @Relationship(inverse: \Game.teams)
    var games: [Game] = []
    
    init(name: String, players: [Player] = []) {
        self.id = UUID()
        self.name = name
        self.players = players
        self.createdDate = Date()
        self.isActive = true
    }
    
    // Calculate average team handicap
    var averageHandicapIndex: Double {
        guard !players.isEmpty else { return 0.0 }
        let totalHandicap = players.reduce(0.0) { $0 + $1.handicapIndex }
        return totalHandicap / Double(players.count)
    }
    
    // Calculate team course handicap
    func teamCourseHandicap(courseRating: Double, slopeRating: Double, par: Int) -> Int {
        let averageHandicap = averageHandicapIndex
        let courseHandicap = (averageHandicap * slopeRating / 113) + (courseRating - Double(par))
        return Int(round(courseHandicap))
    }
    
    // Get best course handicap among team members
    func bestCourseHandicap(courseRating: Double, slopeRating: Double, par: Int) -> Int {
        guard !players.isEmpty else { return 0 }
        return players.map { $0.courseHandicap(courseRating: courseRating, slopeRating: slopeRating, par: par) }.min() ?? 0
    }
    
    // Get worst course handicap among team members
    func worstCourseHandicap(courseRating: Double, slopeRating: Double, par: Int) -> Int {
        guard !players.isEmpty else { return 0 }
        return players.map { $0.courseHandicap(courseRating: courseRating, slopeRating: slopeRating, par: par) }.max() ?? 0
    }
}

//
//  TeamScore.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/16/25.
//

