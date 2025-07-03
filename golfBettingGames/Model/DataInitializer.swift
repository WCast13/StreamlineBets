import Foundation
import SwiftData

class DataInitializer {
    static func createInitialDataIfNeeded(in context: ModelContext) {
        // Check if we already have data
        let descriptor = FetchDescriptor<Course>()
        let existingCourses = try? context.fetch(descriptor)
        
        if existingCourses?.isEmpty ?? true {
            print("Creating initial data...")
            createInitialData(in: context)
        }
    }
    
    private static func createInitialData(in context: ModelContext) {
        // Create a course
        let course = Course(
            name: "Pebble Beach Golf Links",
            par: 72,
            city: "Pebble Beach",
            state: "CA",
            country: "USA"
        )
        course.isFavorite = true
        
        // Add Blue tees
        let blueTees = Tee(
            name: "Blue",
            menRating: 74.0,
            menSlope: 142,
            womenRating: 76.3,
            womenSlope: 148
        )
        blueTees.course = course
        course.tees.append(blueTees)
        
        // Add White tees
        let whiteTees = Tee(
            name: "White",
            menRating: 71.7,
            menSlope: 133,
            womenRating: 74.0,
            womenSlope: 140
        )
        whiteTees.course = course
        course.tees.append(whiteTees)
        
        // Create 18 holes with realistic data
        let holeData: [(par: Int, handicap: Int, distance: Int)] = [
            (4, 7, 380),   // Hole 1
            (5, 13, 502),  // Hole 2
            (4, 15, 388),  // Hole 3
            (4, 9, 327),   // Hole 4
            (3, 17, 166),  // Hole 5
            (5, 1, 513),   // Hole 6
            (3, 11, 106),  // Hole 7
            (4, 3, 418),   // Hole 8
            (4, 5, 450),   // Hole 9
            (4, 8, 426),   // Hole 10
            (4, 10, 373),  // Hole 11
            (3, 16, 188),  // Hole 12
            (4, 2, 392),   // Hole 13
            (5, 6, 565),   // Hole 14
            (4, 12, 365),  // Hole 15
            (4, 14, 332),  // Hole 16
            (3, 18, 172),  // Hole 17
            (5, 4, 542)    // Hole 18
        ]
        
        for (index, data) in holeData.enumerated() {
            let hole = Hole(
                number: index + 1,
                par: data.par,
                handicap: data.handicap,
                distance: data.distance
            )
            hole.course = course
            course.holes.append(hole)
            context.insert(hole)
        }
        
        // Create two players
        let player1 = Player(name: "John Smith", handicapIndex: 8.5)
        let player2 = Player(name: "Mike Johnson", handicapIndex: 12.3)
        
        // Create an active skins game
        let game = Game(
            name: "Saturday Skins",
            gameType: .skins,
            courseName: course.name,
            courseRating: whiteTees.menRating,
            slopeRating: Double(whiteTees.menSlope),
            par: course.par
        )
        game.course = course
        game.selectedTee = whiteTees
        game.selectedGender = .men
        game.players = [player1, player2]
        
        // Create first round (Hole 1)
        let round1 = Round(
            roundNumber: 1,
            holeNumber: 1,
            betAmount: 20.0,
            roundType: .hole
        )
        round1.game = game
        
        // Create scores for round 1
        let score1_1 = PlayerScore(player: player1)
        score1_1.round = round1
        score1_1.score = 4
        score1_1.netScore = 4 // No stroke on hole 1 (handicap 7)
        
        let score1_2 = PlayerScore(player: player2)
        score1_2.round = round1
        score1_2.score = 5
        score1_2.netScore = 5
        
        // Calculate winnings - Player 1 wins
        score1_1.winnings = 20.0
        score1_2.winnings = -20.0
        
        round1.scores = [score1_1, score1_2]
        round1.isCompleted = true
        
        // Create second round (Hole 2) - in progress
        let round2 = Round(
            roundNumber: 2,
            holeNumber: 2,
            betAmount: 20.0,
            roundType: .hole
        )
        round2.game = game
        
        // Create scores for round 2 (not yet entered)
        let score2_1 = PlayerScore(player: player1)
        score2_1.round = round2
        
        let score2_2 = PlayerScore(player: player2)
        score2_2.round = round2
        
        round2.scores = [score2_1, score2_2]
        round2.isCompleted = false
        
        game.rounds = [round1, round2]
        
        // Insert all entities
        context.insert(course)
        context.insert(blueTees)
        context.insert(whiteTees)
        context.insert(player1)
        context.insert(player2)
        context.insert(game)
        context.insert(round1)
        context.insert(round2)
        context.insert(score1_1)
        context.insert(score1_2)
        context.insert(score2_1)
        context.insert(score2_2)
        
        // Save
        do {
            try context.save()
            print("Initial data created successfully")
        } catch {
            print("Failed to create initial data: \(error)")
        }
    }
}
