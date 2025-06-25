//
//  Model.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/19/25.
//

import Foundation
import SwiftData






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

// MARK: - Tee Model

@Model
final class Tee {
    var id: UUID
    var name: String // e.g., "Blue", "White", "Red"
    var menRating: Double
    var menSlope: Int
    var womenRating: Double
    var womenSlope: Int
    
    // Relationship
    var course: Course?
    
    init(
        name: String,
        menRating: Double = 72.0,
        menSlope: Int = 113,
        womenRating: Double = 72.0,
        womenSlope: Int = 113
    ) {
        self.id = UUID()
        self.name = name
        self.menRating = menRating
        self.menSlope = menSlope
        self.womenRating = womenRating
        self.womenSlope = womenSlope
    }
    
    func rating(for gender: Gender) -> Double {
        switch gender {
        case .men: return menRating
        case .women: return womenRating
        }
    }
    
    func slope(for gender: Gender) -> Int {
        switch gender {
        case .men: return menSlope
        case .women: return womenSlope
        }
    }
}

enum Gender: String, CaseIterable, Codable {
    case men = "Men"
    case women = "Women"
}

// MARK: - Course Model
@Model
final class Course {
    var id: UUID
    var name: String
    var par: Int
    var isFavorite: Bool
    
    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \Tee.course)
    var tees: [Tee]
    
    @Relationship(inverse: \Game.course)
    var games: [Game]
    
    init(name: String, par: Int = 72) {
        self.id = UUID()
        self.name = name
        self.par = par
        self.isFavorite = false
        self.tees = []
        self.games = []
    }
    
    var sortedTees: [Tee] {
        // Sort tees by men's rating (typically correlates with difficulty)
        tees.sorted { $0.menRating > $1.menRating }
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

