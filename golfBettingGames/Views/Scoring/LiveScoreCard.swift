//
//  LiveScoreCard.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/7/25.
//


import SwiftUI
import SwiftData

struct LiveScoreCard: View {
    @Bindable var playerScore: PlayerScore
    @Binding var score: Int
    let holeInfo: Hole?
    let courseHandicap: Int
    
    private var strokesOnHole: Int {
        guard let hole = holeInfo else { return 0 }
        return courseHandicap >= hole.handicap ? 1 : 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            
            // Player Info
            VStack {
                Text(playerScore.player?.name ?? "Unknown")
                    .font(.headline)
                    
                
                
                // Current round stats
                if playerScore.score > 0 {
                    VStack(alignment: .trailing) {
                        Text("Total: \(playerScore.score)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            HStack() {
                
                Button(action: {
                    if score > 1 {
                        score -= 1
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.subheadline)
                        .foregroundColor(score > 1 ? .accentColor : .gray)
                }
                .disabled(score <= 1)
                
                Text("\(score)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(minWidth: 50)
                    .foregroundColor(.primary)
                
//                Picker("Score", selection: $score) {
//                    ForEach(1...8, id: \.self) { value in
//                        Text("\(value)").tag(value)
//                    }
//                }
//                .pickerStyle(.segmented)
                
                Button(action: {
                    if score < 12 {
                        score += 1
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.subheadline)
                        .foregroundColor(score < 12 ? .accentColor : .gray)
                }
                .disabled(score >= 12)
                
                Spacer()
                
                if let hole = holeInfo {
                    ScoreToPar(score: score, par: hole.par)
                }
            }
        }
        .padding(.horizontal)
        .cornerRadius(16)
    }
}

// Helper view to show score relative to par
struct ScoreToPar: View {
    let score: Int
    let par: Int
    
    private var difference: Int { score - par }
    
    private var label: String {
        switch difference {
        case ..<(-2): return "Eagle or better"
        case -2: return "Eagle"
        case -1: return "Birdie"
        case 0: return "Par"
        case 1: return "Bogey"
        case 2: return "Double Bogey"
        case 3: return "Triple Bogey"
        default: return "+\(difference)"
        }
    }
    
    private var color: Color {
        switch difference {
        case ..<0: return .green
        case 0: return .primary
        case 1: return .orange
        default: return .red
        }
    }
    
    var body: some View {
        Text(label)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .cornerRadius(8)
    }
}

//#Preview("Player with Stroke") {
//    let config = ModelConfiguration(isStoredInMemoryOnly: true)
//    let container = try! ModelContainer(
//        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
//        configurations: config
//    )
//    
//    let context = container.mainContext
//    
//    // Create course and hole
//    let course = Course(name: "Test Course", par: 72)
//    let hole = Hole(number: 5, par: 4, handicap: 3, distance: 420)
//    hole.course = course
//    course.holes.append(hole)
//    
//    // Create player with handicap that will get a stroke on this hole
//    let player = Player(name: "John Smith", handicapIndex: 18.5)
//    
//    // Create game
//    let game = Game(
//        name: "Test Game",
//        gameType: .skins,
//        courseName: course.name,
//        courseRating: 72.0,
//        slopeRating: 130.0,
//        par: 72
//    )
//    game.course = course
//    
//    // Create round
//    let round = Round(
//        roundNumber: 1,
//        betAmount: 20.0,
//        roundType: .full18
//    )
//    round.game = game
//    
//    // Create player score
//    let playerScore = PlayerScore(player: player)
//    playerScore.round = round
//    playerScore.score = 36 // Total score so far
//    
//    // Insert all
//    context.insert(course)
//    context.insert(hole)
//    context.insert(player)
//    context.insert(game)
//    context.insert(round)
//    context.insert(playerScore)
//    
//    try! context.save()
//    
//    // Preview state
//    @State var score = 5
//    return VStack {
//        LiveScoreCard(
//            playerScore: playerScore,
//            score: $score,
//            holeInfo: hole,
//            courseHandicap: 22 // High handicap player gets stroke on handicap 3 hole
//        )
//        .padding()
//    }
//    .background(Color(UIColor.systemGroupedBackground))
//}
//
////#Preview("Player without Stroke") {
////    let config = ModelConfiguration(isStoredInMemoryOnly: true)
////    let container = try! ModelContainer(
////        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
////        configurations: config
////    )
////    
////    let context = container.mainContext
////    
////    // Create course and hole
////    let course = Course(name: "Test Course", par: 72)
////    let hole = Hole(number: 15, par: 4, handicap: 12, distance: 385)
////    hole.course = course
////    course.holes.append(hole)
////    
////    // Create scratch player
////    let player = Player(name: "Tiger Woods", handicapIndex: 0.5)
////    
////    // Create game
////    let game = Game(
////        name: "Test Game",
////        gameType: .skins,
////        courseName: course.name,
////        courseRating: 72.0,
////        slopeRating: 130.0,
////        par: 72
////    )
////    game.course = course
////    
////    // Create round
////    let round = Round(
////        roundNumber: 1,
////        betAmount: 50.0,
////        roundType: .full18
////    )
////    round.game = game
////    
////    // Create player score
////    let playerScore = PlayerScore(player: player)
////    playerScore.round = round
////    playerScore.score = 58 // Total score so far
////    
////    // Insert all
////    context.insert(course)
////    context.insert(hole)
////    context.insert(player)
////    context.insert(game)
////    context.insert(round)
////    context.insert(playerScore)
////    
////    try! context.save()
////    
////    // Preview state
////    @State var score = 3 // Birdie
////    
////    return VStack {
////        LiveScoreCard(
////            playerScore: playerScore,
////            score: $score,
////            holeInfo: hole,
////            courseHandicap: 1 // Low handicap, no stroke on this hole
////        )
////        .padding()
////    }
////    .background(Color(UIColor.systemGroupedBackground))
////}
////
////#Preview("Par 3 Hole") {
////    let config = ModelConfiguration(isStoredInMemoryOnly: true)
////    let container = try! ModelContainer(
////        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
////        configurations: config
////    )
////    
////    let context = container.mainContext
////    
////    // Create course and par 3 hole
////    let course = Course(name: "Test Course", par: 72)
////    let hole = Hole(number: 7, par: 3, handicap: 17, distance: 165)
////    hole.course = course
////    course.holes.append(hole)
////    
////    // Create mid-handicap player
////    let player = Player(name: "Average Joe", handicapIndex: 12.0)
////    
////    // Create game
////    let game = Game(
////        name: "Test Game",
////        gameType: .skins,
////        courseName: course.name,
////        courseRating: 72.0,
////        slopeRating: 125.0,
////        par: 72
////    )
////    game.course = course
////    
////    // Create round
////    let round = Round(
////        roundNumber: 1,
////        betAmount: 10.0,
////        roundType: .full18
////    )
////    round.game = game
////    
////    // Create player score
////    let playerScore = PlayerScore(player: player)
////    playerScore.round = round
////    playerScore.score = 0 // Just starting
////    
////    // Insert all
////    context.insert(course)
////    context.insert(hole)
////    context.insert(player)
////    context.insert(game)
////    context.insert(round)
////    context.insert(playerScore)
////    
////    try! context.save()
////    
////    // Preview state
////    @State var score = 4 // Bogey on par 3
////    
////    return VStack {
////        LiveScoreCard(
////            playerScore: playerScore,
////            score: $score,
////            holeInfo: hole,
////            courseHandicap: 14 // No stroke on handicap 17 hole
////        )
////        .padding()
////    }
////    .background(Color(UIColor.systemGroupedBackground))
////}
////
////#Preview("Par 5 with Eagle") {
////    let config = ModelConfiguration(isStoredInMemoryOnly: true)
////    let container = try! ModelContainer(
////        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
////        configurations: config
////    )
////    
////    let context = container.mainContext
////    
////    // Create course and par 5 hole
////    let course = Course(name: "Test Course", par: 72)
////    let hole = Hole(number: 14, par: 5, handicap: 6, distance: 545)
////    hole.course = course
////    course.holes.append(hole)
////    
////    // Create good player
////    let player = Player(name: "Pro Player", handicapIndex: 4.2)
////    
////    // Create game
////    let game = Game(
////        name: "Test Game",
////        gameType: .skins,
////        courseName: course.name,
////        courseRating: 72.0,
////        slopeRating: 135.0,
////        par: 72
////    )
////    game.course = course
////    
////    // Create round
////    let round = Round(
////        roundNumber: 1,
////        betAmount: 100.0,
////        roundType: .full18
////    )
////    round.game = game
////    
////    // Create player score
////    let playerScore = PlayerScore(player: player)
////    playerScore.round = round
////    
////    // Insert all
////    context.insert(course)
////    context.insert(hole)
////    context.insert(player)
////    context.insert(game)
////    context.insert(round)
////    context.insert(playerScore)
////    
////    try! context.save()
////    
////    // Preview state
////    @State var score = 3 // Eagle!
////    
////    return VStack {
////        LiveScoreCard(
////            playerScore: playerScore,
////            score: $score,
////            holeInfo: hole,
////            courseHandicap: 5 // No stroke on handicap 6 hole
////        )
////        .padding()
////    }
////    .background(Color(UIColor.systemGroupedBackground))
////}
////
#Preview("Multiple Cards") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
        configurations: config
    )
    
    let context = container.mainContext
    
    // Create course and hole
    let course = Course(name: "Test Course", par: 72)
    let hole = Hole(number: 9, par: 4, handicap: 1, distance: 445)
    hole.course = course
    course.holes.append(hole)
    
    // Create multiple players
    let player1 = Player(name: "Scratch Player", handicapIndex: 0.0)
    let player2 = Player(name: "High Handicapper", handicapIndex: 24.5)
    let player3 = Player(name: "Mid Handicapper", handicapIndex: 12.0)
    
    // Create game
    let game = Game(
        name: "Test Game",
        gameType: .skins,
        courseName: course.name,
        courseRating: 72.0,
        slopeRating: 130.0,
        par: 72
    )
    game.course = course
    
    // Create round
    let round = Round(
        roundNumber: 1,
        betAmount: 20.0,
        roundType: .full18
    )
    round.game = game
    
    // Create player scores
    let score1 = PlayerScore(player: player1)
    score1.round = round
    
    let score2 = PlayerScore(player: player2)
    score2.round = round
    
    let score3 = PlayerScore(player: player3)
    score3.round = round
    
    // Insert all
    context.insert(course)
    context.insert(hole)
    context.insert(player1)
    context.insert(player2)
    context.insert(player3)
    context.insert(game)
    context.insert(round)
    context.insert(score1)
    context.insert(score2)
    context.insert(score3)
    
    try! context.save()
    
    // Preview states
    @State var scoreValue1 = 4
    @State var scoreValue2 = 6
    @State var scoreValue3 = 5
    
    return ScrollView {
        VStack(spacing: 16) {
            Text("Multiple Players - Hole 9 (Hardest Hole)")
                .font(.headline)
                .padding(.top)
            
            LiveScoreCard(
                playerScore: score1,
                score: $scoreValue1,
                holeInfo: hole,
                courseHandicap: 0 // Scratch player, no strokes
            )
            
            LiveScoreCard(
                playerScore: score2,
                score: $scoreValue2,
                holeInfo: hole,
                courseHandicap: 40 // Gets stroke on every hole
            )
            
            LiveScoreCard(
                playerScore: score3,
                score: $scoreValue3,
                holeInfo: hole,
                courseHandicap: 14 // Gets stroke on holes 1-14
            )
        }
        .padding()
    }
    .background(Color(UIColor.systemGroupedBackground))
    .modelContainer(container)
}

