//
//  ScoreEntryView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/25/25.
//

import SwiftUI
import SwiftData

// MARK: - ScoreEntryView.swift
struct ScoreEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var score: PlayerScore
    let round: Round
    let onSave: () -> Void
    
    @State private var grossScore: Int
    @State private var notes: String
    
    private var courseHandicap: Int {
        guard let player = score.player,
              let game = round.game else { return 0 }
        
        return player.courseHandicap(
            courseRating: game.courseRating,
            slopeRating: game.slopeRating,
            par: game.par
        )
    }
    
    private var strokesForHole: Int {
        if round.roundType == .hole, let holeNumber = round.holeNumber {
            // Standard stroke allocation
            return courseHandicap >= holeNumber ? 1 : 0
        }
        return 0
    }
    
    init(score: PlayerScore, round: Round, onSave: @escaping () -> Void) {
        self.score = score
        self.round = round
        self.onSave = onSave
        self._grossScore = State(initialValue: score.score > 0 ? score.score : 4)
        self._notes = State(initialValue: score.notes)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(score.player?.name ?? "Unknown")
                        .font(.headline)
                    
                    if let holeNumber = round.holeNumber {
                        LabeledContent("Hole", value: "\(holeNumber)")
                    }
                    
                    LabeledContent("Course Handicap", value: "\(courseHandicap)")
                    
                    if strokesForHole > 0 {
                        LabeledContent("Strokes on this hole", value: "\(strokesForHole)")
                            .foregroundColor(.blue)
                    }
                } header: {
                    Text("Player Information")
                }
                
                Section {
                    Stepper("Gross Score: \(grossScore)",
                           value: $grossScore,
                           in: 1...15)
                    
                    LabeledContent("Net Score") {
                        Text("\(grossScore - strokesForHole)")
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                } header: {
                    Text("Score Entry")
                }
                
                Section {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Notes")
                }
            }
            .navigationTitle("Enter Score")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveScore()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func saveScore() {
        score.score = grossScore
        score.netScore = grossScore - strokesForHole
        score.notes = notes
        onSave()
        dismiss()
    }
}

// MARK: - ScoreEntryView Preview
#Preview("New Score Entry") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
        configurations: config
    )
    
    let context = container.mainContext
    
    // Create course
    let course = Course(name: "Pebble Beach", par: 72)
    
    // Create player
    let player = Player(name: "John Smith", handicapIndex: 12.5)
    
    // Create game
    let game = Game(
        name: "Weekend Round",
        gameType: .strokePlay,
        courseName: course.name,
        courseRating: 74.5,
        slopeRating: 135.0,
        par: 72
    )
    game.course = course
    game.players = [player]
    
    // Create round
    let round = Round(
        roundNumber: 1,
        betAmount: 20.0,
        roundType: .full18
    )
    round.game = game
    
    // Create player score (no score entered yet)
    let playerScore = PlayerScore(player: player)
    playerScore.round = round
    
    context.insert(course)
    context.insert(player)
    context.insert(game)
    context.insert(round)
    context.insert(playerScore)
    
    try! context.save()
    
    return ScoreEntryView(
        score: playerScore,
        round: round,
        onSave: {
            print("Score saved")
        }
    )
    .modelContainer(container)
}

#Preview("Single Hole with Strokes") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
        configurations: config
    )
    
    let context = container.mainContext
    
    // Create course with specific hole
    let course = Course(name: "Augusta National", par: 72)
    let hole = Hole(number: 11, par: 4, handicap: 11, distance: 505)
    hole.course = course
    course.holes.append(hole)
    
    // Create high handicap player (will get stroke on hole 11)
    let player = Player(name: "Weekend Warrior", handicapIndex: 18.5)
    
    // Create game
    let game = Game(
        name: "Single Hole Bet",
        gameType: .skins,
        courseName: course.name,
        courseRating: 76.2,
        slopeRating: 148.0,
        par: 72
    )
    game.course = course
    game.players = [player]
    
    // Create single hole round
    let round = Round(
        roundNumber: 1,
        holeNumber: 11,
        betAmount: 50.0,
        roundType: .hole
    )
    round.game = game
    
    // Create player score
    let playerScore = PlayerScore(player: player)
    playerScore.round = round
    
    context.insert(course)
    context.insert(hole)
    context.insert(player)
    context.insert(game)
    context.insert(round)
    context.insert(playerScore)
    
    try! context.save()
    
    return ScoreEntryView(
        score: playerScore,
        round: round,
        onSave: {
            print("Single hole score saved")
        }
    )
    .modelContainer(container)
}

#Preview("Existing Score with Notes") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
        configurations: config
    )
    
    let context = container.mainContext
    
    // Create course
    let course = Course(name: "St. Andrews", par: 72)
    
    // Create player
    let player = Player(name: "Tiger Woods", handicapIndex: 0.0)
    
    // Create game
    let game = Game(
        name: "The Open Championship",
        gameType: .strokePlay,
        courseName: course.name,
        courseRating: 72.0,
        slopeRating: 113.0,
        par: 72
    )
    game.course = course
    game.players = [player]
    
    // Create round
    let round = Round(
        roundNumber: 3,
        betAmount: 100.0,
        roundType: .full18
    )
    round.game = game
    
    // Create player score with existing data
    let playerScore = PlayerScore(player: player, score: 68, netScore: 68)
    playerScore.notes = "Great round! Eagle on 14, birdie on 17. Struggled with the wind on the front nine."
    playerScore.round = round
    
    context.insert(course)
    context.insert(player)
    context.insert(game)
    context.insert(round)
    context.insert(playerScore)
    
    try! context.save()
    
    return ScoreEntryView(
        score: playerScore,
        round: round,
        onSave: {
            print("Updated score saved")
        }
    )
    .modelContainer(container)
}

#Preview("High Handicap Player") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
        configurations: config
    )
    
    let context = container.mainContext
    
    // Create course
    let course = Course(name: "Local Municipal", par: 72)
    
    // Create high handicap player
    let player = Player(name: "Beginner Golfer", handicapIndex: 36.0)
    
    // Create game
    let game = Game(
        name: "Friendly Game",
        gameType: .strokePlay,
        courseName: course.name,
        courseRating: 68.5,
        slopeRating: 115.0,
        par: 72
    )
    game.course = course
    game.players = [player]
    
    // Create round
    let round = Round(
        roundNumber: 1,
        betAmount: 10.0,
        roundType: .front9
    )
    round.game = game
    
    // Create player score
    let playerScore = PlayerScore(player: player)
    playerScore.round = round
    
    context.insert(course)
    context.insert(player)
    context.insert(game)
    context.insert(round)
    context.insert(playerScore)
    
    try! context.save()
    
    return ScoreEntryView(
        score: playerScore,
        round: round,
        onSave: {
            print("High handicap score saved")
        }
    )
    .modelContainer(container)
}

#Preview("Interactive Demo") {
    struct InteractiveDemo: View {
        @State private var savedScore: String = "No score saved yet"
        
        var body: some View {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try! ModelContainer(
                for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
                configurations: config
            )
            
            let context = container.mainContext
            
            // Create course
            let course = Course(name: "TPC Sawgrass", par: 72)
            
            // Create player
            let player = Player(name: "Interactive Player", handicapIndex: 8.5)
            
            // Create game
            let game = Game(
                name: "Demo Game",
                gameType: .skins,
                courseName: course.name,
                courseRating: 76.0,
                slopeRating: 155.0,
                par: 72
            )
            game.course = course
            game.players = [player]
            
            // Create round
            let round = Round(
                roundNumber: 1,
                betAmount: 25.0,
                roundType: .full18
            )
            round.game = game
            
            // Create player score
            let playerScore = PlayerScore(player: player)
            playerScore.round = round
            
            context.insert(course)
            context.insert(player)
            context.insert(game)
            context.insert(round)
            context.insert(playerScore)
            
            try! context.save()
            
            return VStack {
                ScoreEntryView(
                    score: playerScore,
                    round: round,
                    onSave: {
                        savedScore = "Saved: Gross \(playerScore.score), Net \(playerScore.netScore)"
                        if !playerScore.notes.isEmpty {
                            savedScore += "\nNotes: \(playerScore.notes)"
                        }
                    }
                )
                .modelContainer(container)
                
                // Show saved result
                Text(savedScore)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                    .cornerRadius(8)
                    .padding()
            }
        }
    }
    
    return InteractiveDemo()
}

