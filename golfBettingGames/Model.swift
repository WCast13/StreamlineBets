//
//  Model.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/19/25.
//

import Foundation
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


// MARK: - Round Model
@Model
final class Round {
    var id: UUID
    var roundNumber: Int
    var holeNumber: Int?
    var date: Date
    var betAmount: Double
    var roundType: RoundType
    var isCompleted: Bool
    
    // Relationships
    var game: Game?
    
    @Relationship(deleteRule: .cascade, inverse: \PlayerScore.round)
    var scores: [PlayerScore]
    
    init(roundNumber: Int, holeNumber: Int? = nil, betAmount: Double, roundType: RoundType) {
        self.id = UUID()
        self.roundNumber = roundNumber
        self.holeNumber = holeNumber
        self.date = Date()
        self.betAmount = betAmount
        self.roundType = roundType
        self.isCompleted = false
        self.scores = []
    }
}

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
    
    init(player: Player, score: Int, netScore: Int, winnings: Double = 0.0) {
        self.id = UUID()
        self.player = player
        self.score = score
        self.netScore = netScore
        self.winnings = winnings
        self.notes = ""
    }
}

// MARK: - Enums
enum GameType: String, Codable, CaseIterable {
    case skins = "Skins"
    case nassau = "Nassau"
    case matchPlay = "Match Play"
    case strokePlay = "Stroke Play"
    case wolf = "Wolf"
    case bestBall = "Best Ball"
    case scramble = "Scramble"
    case custom = "Custom"
    
    var description: String {
        return self.rawValue
    }
}

enum RoundType: String, Codable, CaseIterable {
    case front9 = "Front 9"
    case back9 = "Back 9"
    case full18 = "Full 18"
    case hole = "Single Hole"
    case custom = "Custom"
    
    var description: String {
        return self.rawValue
    }
}

// MARK: - SwiftData Model Container
extension ModelContainer {
    static var golfBettingContainer: ModelContainer = {
        let schema = Schema([
            Player.self,
            Game.self,
            Round.self,
            PlayerScore.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}

// MARK: - Sample Data Generator (for development/testing)
extension ModelContainer {
    static func createSampleData(in context: ModelContext) {
        // Create sample players
        let player1 = Player(name: "John Doe", handicapIndex: 12.5)
        let player2 = Player(name: "Jane Smith", handicapIndex: 8.3)
        let player3 = Player(name: "Bob Johnson", handicapIndex: 15.7)
        let player4 = Player(name: "Alice Brown", handicapIndex: 5.2)
        
        context.insert(player1)
        context.insert(player2)
        context.insert(player3)
        context.insert(player4)
        
        // Create a sample game
        let game = Game(
            name: "Saturday Skins",
            gameType: .skins,
            courseName: "Pine Valley Golf Club",
            courseRating: 73.2,
            slopeRating: 125,
            par: 72
        )
        game.players = [player1, player2, player3, player4]
        context.insert(game)
        
        // Create sample rounds
        let round1 = Round(roundNumber: 1, holeNumber: 1, betAmount: 10.0, roundType: .hole)
        round1.game = game
        
        // Add scores for round 1
        let score1 = PlayerScore(player: player1, score: 5, netScore: 4, winnings: -10.0)
        let score2 = PlayerScore(player: player2, score: 4, netScore: 4, winnings: -10.0)
        let score3 = PlayerScore(player: player3, score: 6, netScore: 5, winnings: -10.0)
        let score4 = PlayerScore(player: player4, score: 3, netScore: 3, winnings: 30.0)
        
        round1.scores = [score1, score2, score3, score4]
        context.insert(round1)
        
        // Save the context
        do {
            try context.save()
        } catch {
            print("Failed to save sample data: \(error)")
        }
    }
}
