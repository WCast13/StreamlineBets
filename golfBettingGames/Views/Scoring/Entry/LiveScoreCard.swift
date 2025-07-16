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
    let gameType: GameType
    let allScores: [PlayerScore]
    
    @State private var scoreOptions: [Int] = []
    
    private var strokesOnHole: Int {
        guard let hole = holeInfo else { return 0 }
        return courseHandicap >= hole.handicap ? 1 : 0
    }
    
    var body: some View {
        HStack(spacing: 6) {
            // Player Name
            VStack(alignment: .leading, spacing: 0) {
                Text(playerScore.player?.name ?? "Unknown")
                    .font(.caption)
                    .fontWeight(.medium)
                
                if strokesOnHole > 0 {
                    if let hole = holeInfo {
                        ScoreToParPill(score: score, par: hole.par)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Quick Score Buttons
            if let hole = holeInfo {
                HStack(spacing: 2) {
                    Button(action: {
                        // Shift options down
                        if let first = scoreOptions.first { scoreOptions = scoreOptions.map { $0 - 1 } }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12, weight: .medium))
                            .frame(width: 20, height: 22)
                    }
                    .disabled(scoreOptions.first ?? 1 <= 1)
                    ForEach(scoreOptions, id: \.self) { scoreValue in
                        ScoreButton(
                            value: scoreValue,
                            isSelected: score == scoreValue,
                            action: {
                                score = scoreValue
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                        )
                    }
                    Button(action: {
                        // Shift options up
                        if let last = scoreOptions.last { scoreOptions = scoreOptions.map { $0 + 1 } }
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .frame(width: 20, height: 22)
                    }
                    .disabled(scoreOptions.last ?? 0 >= 10)
                }
                .onAppear {
                    // Initialize scoreOptions when the view appears
                    if scoreOptions.isEmpty, let hole = holeInfo {
                        scoreOptions = [hole.par - 2, hole.par - 1, hole.par, hole.par + 1, hole.par + 2, hole.par + 3]
                    }
                }
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 3)
        .cornerRadius(8)
    }
}

// MARK: - Score Button
struct ScoreButton: View {
    let value: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(value)")
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .frame(width: 22, height: 22)
                .background(
                    Circle()
                        .fill(isSelected ? Color.accentColor : Color.gray.opacity(0.15))
                )
        }
    }
}

// MARK: - Score to Par
struct ScoreToPar: View {
    let score: Int
    let par: Int
    
    private var difference: Int { score - par }
    
    private var label: String {
        switch difference {
        case -2: return "E"
        case -1: return "B"
        case 0: return "P"
        case 1: return "+1"
        case 2: return "+2"
        default: return difference > 0 ? "+\(difference)" : "\(difference)"
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
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(color.opacity(0.15))
            )
    }
}

// MARK: - Preview
#Preview("Compact Score Cards") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
        configurations: config
    )
    
    let context = container.mainContext
    
    // Create course and hole
    let course = Course(name: "Test Course", par: 72)
    let hole = Hole(number: 5, par: 4, handicap: 3, distance: 420)
    hole.course = course
    course.holes.append(hole)
    
    // Create players
    let player1 = Player(name: "John Smith", handicapIndex: 10.0)
    let player2 = Player(name: "Sarah Johnson", handicapIndex: 15.0)
    let player3 = Player(name: "Mike Williams", handicapIndex: 5.0)
    
    // Create game
    let game = Game(
        name: "Weekend Round",
        gameType: .strokePlay,
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
    
    round.scores = [score1, score2, score3]
    
    context.insert(course)
    context.insert(hole)
    context.insert(player1)
    context.insert(player2)
    context.insert(player3)
    context.insert(game)
    context.insert(round)
    
    try! context.save()
    
    @State var scores = [4, 5, 3]
    
    return VStack(spacing: 8) {
        Text("Hole 5 • Par 4")
            .font(.headline)
            .padding(.top)
        
        ForEach(Array(zip(round.scores, scores.indices)), id: \.0.id) { playerScore, index in
            LiveScoreCard(
                playerScore: playerScore,
                score: Binding(
                    get: { scores[index] },
                    set: { scores[index] = $0 }
                ),
                holeInfo: hole,
                courseHandicap: 12,
                gameType: .strokePlay,
                allScores: round.scores
            )
        }
        
        Spacer()
    }
    .padding()
    .modelContainer(container)
}

#Preview("Par 3 Hole") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
        configurations: config
    )
    
    let context = container.mainContext
    
    // Create course and hole
    let course = Course(name: "Test Course", par: 72)
    let hole = Hole(number: 12, par: 3, handicap: 15, distance: 165)
    hole.course = course
    course.holes.append(hole)
    
    // Create player
    let player = Player(name: "Test Player", handicapIndex: 18.0)
    
    // Create game
    let game = Game(
        name: "Test Game",
        gameType: .strokePlay,
        courseName: course.name,
        courseRating: 72.0,
        slopeRating: 130.0,
        par: 72
    )
    game.course = course
    
    // Create round
    let round = Round(
        roundNumber: 1,
        betAmount: 10.0,
        roundType: .full18
    )
    round.game = game
    
    // Create player score
    let playerScore = PlayerScore(player: player)
    playerScore.round = round
    round.scores = [playerScore]
    
    context.insert(course)
    context.insert(hole)
    context.insert(player)
    context.insert(game)
    context.insert(round)
    
    try! context.save()
    
    @State var score = 3
    
    return VStack(spacing: 16) {
        Text("Par 3 Example")
            .font(.headline)
        
        LiveScoreCard(
            playerScore: playerScore,
            score: $score,
            holeInfo: hole,
            courseHandicap: 20,
            gameType: .strokePlay,
            allScores: [playerScore]
        )
        
        Spacer()
    }
    .padding()
    .modelContainer(container)
}
// MARK: - Score to Par Pill
struct ScoreToParPill: View {
    let score: Int
    let par: Int
    
    private var difference: Int { score - par }
    
    private var label: String {
        if score == 1 { return "Ace" }
        switch difference {
        case -3: return "Double Eagle"
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
    
    private var icon: String {
        switch difference {
        case ..<(-1): return "star.fill"
        case 0: return "checkmark.circle.fill"
        case 1: return "exclamationmark.circle"
        default: return "xmark.circle"
        }
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .foregroundColor(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(color.opacity(0.15))
        )
        .overlay(
            Capsule()
                .stroke(color.opacity(0.3), lineWidth: 0.5)
        )
    }
}

