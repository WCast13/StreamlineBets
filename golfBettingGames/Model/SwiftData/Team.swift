//
//  Team.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/16/25.
//

import Foundation
import SwiftData

// MARK: - Team Model
@Model
final class Team {
    var id: UUID
    var name: String
    var color: String // Hex color string for team identification
    var createdDate: Date
    var isActive: Bool
    
    // Team statistics
    var totalWinnings: Double
    var gamesPlayed: Int
    var gamesWon: Int
    
    // Relationships
    @Relationship(inverse: \Player.teams)
    var players: [Player] = []
    
    @Relationship(inverse: \Game.teams)
    var games: [Game] = []
    
    @Relationship(inverse: \Round.teams)
    var rounds: [Round] = []
    
    init(
        name: String,
        color: String = "#007AFF", // Default to system blue
        players: [Player] = []
    ) {
        self.id = UUID()
        self.name = name
        self.color = color
        self.createdDate = Date()
        self.isActive = true
        self.totalWinnings = 0.0
        self.gamesPlayed = 0
        self.gamesWon = 0
        self.players = players
    }
    
    // MARK: - Computed Properties
    
    var winPercentage: Double {
        guard gamesPlayed > 0 else { return 0 }
        return Double(gamesWon) / Double(gamesPlayed) * 100
    }
    
    var averageHandicap: Double {
        guard !players.isEmpty else { return 0 }
        let totalHandicap = players.reduce(0) { $0 + $1.handicapIndex }
        return totalHandicap / Double(players.count)
    }
    
    var combinedCourseHandicap: Int {
        // For team games, often the combined course handicap is used
        // This would need to be calculated based on the specific course/game
        return 0 // Placeholder - would be calculated based on game context
    }
    
    // MARK: - Methods
    
    func addPlayer(_ player: Player) {
        if !players.contains(player) {
            players.append(player)
        }
    }
    
    func removePlayer(_ player: Player) {
        players.removeAll { $0.id == player.id }
    }
    
    func updateStatistics() {
        // Calculate total winnings from all rounds
        totalWinnings = rounds.reduce(0) { total, round in
            // Sum winnings for all team members in this round
            let roundWinnings = round.scores
                .filter { score in
                    guard let player = score.player else { return false }
                    return players.contains(player)
                }
                .reduce(0) { $0 + $1.winnings }
            return total + roundWinnings
        }
        
        // Update games played and won
        gamesPlayed = games.count
        gamesWon = games.filter { game in
            // Determine if this team won the game
            // Logic would depend on game type and scoring
            false // Placeholder
        }.count
    }
    
    func totalForGame(_ game: Game) -> Double {
        // Calculate total winnings/losses for this team in a specific game
        var total = 0.0
        for round in game.rounds {
            for score in round.scores {
                if let player = score.player, players.contains(player) {
                    total += score.winnings
                }
            }
        }
        return total
    }
}

// MARK: - Team Extensions

extension Team {
    // Convenience method to create a team name from player names
    static func generateTeamName(from players: [Player]) -> String {
        guard !players.isEmpty else { return "New Team" }
        
        if players.count == 1 {
            return "\(players[0].name)'s Team"
        } else if players.count == 2 {
            let names = players.map { $0.name.split(separator: " ").first ?? "" }
            return "\(names[0]) & \(names[1])"
        } else {
            return "Team \(players.first?.name.split(separator: " ").first ?? "Golf")"
        }
    }
    
    // Predefined team colors
    static let teamColors = [
        "#007AFF", // Blue
        "#34C759", // Green
        "#FF3B30", // Red
        "#FF9500", // Orange
        "#AF52DE", // Purple
        "#5856D6", // Indigo
        "#FF2D55", // Pink
        "#00C7BE", // Teal
        "#32ADE6", // Light Blue
        "#FFCC00", // Yellow
    ]
}

// MARK: - Identifiable Conformance
extension Team: Identifiable {}

// MARK: - Hashable Conformance
extension Team: Hashable {
    static func == (lhs: Team, rhs: Team) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
