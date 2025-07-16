//
//  RoundStatusCard.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/7/25.
//


import SwiftUI
import SwiftData

struct RoundStatusCard: View {
    let round: Round
    @State private var showingLiveScoring = false
    
    private var holesCompleted: Int {
        guard let firstScore = round.scores.first else { return 0 }
        return firstScore.holeScores.count
    }
    
    private var totalHoles: Int {
        switch round.roundType {
        case .hole: return 1
        case .front9, .back9: return 9
        case .full18: return 18
        case .custom: return round.holesPlayed
        }
    }
    
    private var progressPercentage: Double {
        guard totalHoles > 0 else { return 0 }
        return Double(holesCompleted) / Double(totalHoles)
    }
    
    private var currentLeader: (player: Player?, score: Int)? {
        let validScores = round.scores.filter { $0.score > 0 }
        guard let lowestScore = validScores.min(by: { $0.netScore < $1.netScore }) else { return nil }
        return (lowestScore.player, lowestScore.netScore)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Round Status")
                        .font(.headline)
                    
                    if round.isCompleted {
                        Label("Completed", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Label("In Progress", systemImage: "flag.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                if !round.isCompleted {
                    QuickScoreButton(round: round, size: .small)
                }
            }
            
            // Progress Bar
            if !round.isCompleted && round.roundType != .hole {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("\(holesCompleted) of \(totalHoles) holes completed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(progressPercentage * 100))%")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.orange, Color.orange.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * progressPercentage, height: 8)
                                .animation(.easeInOut(duration: 0.3), value: progressPercentage)
                        }
                    }
                    .frame(height: 8)
                }
            }
            
            // Stats Grid
            HStack(spacing: 16) {
                StatCard(
                    title: "Players",
                    value: "\(round.scores.count)",
                    icon: "person.2.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Bet Amount",
                    value: "$\(Int(round.betAmount))",
                    icon: "dollarsign.circle.fill",
                    color: .green
                )
                
                if let leader = currentLeader {
                    StatCard(
                        title: "Leader",
                        value: leader.player?.name ?? "Unknown",
                        subtitle: "Net: \(leader.score)",
                        icon: "trophy.fill",
                        color: .orange
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct StatCard: View {
    let title: String
    let value: String
    var subtitle: String? = nil
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.headline)
                    .lineLimit(1)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - RoundStatusCard Preview
#Preview("In Progress - Full 18") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
        configurations: config
    )
    
    let context = container.mainContext
    
    // Create course
    let course = Course(name: "Pebble Beach", par: 72)
    
    // Create holes
    for i in 1...18 {
        let hole = Hole(
            number: i,
            par: [4, 5, 4, 4, 3, 5, 3, 4, 4, 4, 4, 3, 4, 5, 5, 4, 3, 5][i-1],
            handicap: i,
            distance: 400
        )
        hole.course = course
        course.holes.append(hole)
        context.insert(hole)
    }
    
    // Create players
    let player1 = Player(name: "Tiger Woods", handicapIndex: 0.0)
    let player2 = Player(name: "Phil Mickelson", handicapIndex: 5.2)
    let player3 = Player(name: "Rory McIlroy", handicapIndex: 2.8)
    
    // Create game
    let game = Game(
        name: "Weekend Round",
        gameType: .skins,
        courseName: course.name,
        courseRating: 72.0,
        slopeRating: 130.0,
        par: 72
    )
    game.course = course
    game.players = [player1, player2, player3]
    
    // Create round in progress
    let round = Round(
        roundNumber: 1,
        betAmount: 50.0,
        roundType: .full18
    )
    round.game = game
    round.isCompleted = false
    
    // Create scores with 7 holes completed
    let score1 = PlayerScore(player: player1)
    let score2 = PlayerScore(player: player2)
    let score3 = PlayerScore(player: player3)
    
    // Add hole scores for first 7 holes
    for i in 1...7 {
        let hs1 = HoleScore(holeNumber: i, grossScore: course.holes[i-1].par + (i == 3 ? -1 : 0))
        hs1.playerScore = score1
        score1.holeScores.append(hs1)
        
        let hs2 = HoleScore(holeNumber: i, grossScore: course.holes[i-1].par + (i == 5 ? 1 : 0))
        hs2.playerScore = score2
        score2.holeScores.append(hs2)
        
        let hs3 = HoleScore(holeNumber: i, grossScore: course.holes[i-1].par + (i == 2 ? 2 : 0))
        hs3.playerScore = score3
        score3.holeScores.append(hs3)
    }
    
    // Update total scores
    score1.updateTotalScores()
    score2.updateTotalScores()
    score3.updateTotalScores()
    
    score1.round = round
    score2.round = round
    score3.round = round
    
    round.scores = [score1, score2, score3]
    round.holesPlayed = 7
    
    // Insert all entities
    context.insert(course)
    context.insert(player1)
    context.insert(player2)
    context.insert(player3)
    context.insert(game)
    context.insert(round)
    context.insert(score1)
    context.insert(score2)
    context.insert(score3)
    
    try! context.save()
    
    return ScrollView {
        VStack(spacing: 20) {
            RoundStatusCard(round: round)
                .padding()
        }
    }
    .background(Color(UIColor.systemGroupedBackground))
    .modelContainer(container)
}

#Preview("Completed Round") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
        configurations: config
    )
    
    let context = container.mainContext
    
    // Create course
    let course = Course(name: "Augusta National", par: 72)
    
    // Create simplified holes
    for i in 1...18 {
        let hole = Hole(number: i, par: 4, handicap: i, distance: 400)
        hole.course = course
        course.holes.append(hole)
        context.insert(hole)
    }
    
    // Create players
    let player1 = Player(name: "Jordan Spieth", handicapIndex: 3.2)
    let player2 = Player(name: "Justin Thomas", handicapIndex: 1.8)
    
    // Create game
    let game = Game(
        name: "Masters Practice",
        gameType: .matchPlay,
        courseName: course.name,
        courseRating: 72.0,
        slopeRating: 135.0,
        par: 72
    )
    game.course = course
    game.players = [player1, player2]
    
    // Create completed round
    let round = Round(
        roundNumber: 1,
        betAmount: 100.0,
        roundType: .full18
    )
    round.game = game
    round.isCompleted = true
    
    // Create complete scores
    let score1 = PlayerScore(player: player1)
    let score2 = PlayerScore(player: player2)
    
    // Add all 18 hole scores
    for i in 1...18 {
        let hs1 = HoleScore(holeNumber: i, grossScore: 4)
        hs1.playerScore = score1
        score1.holeScores.append(hs1)
        
        let hs2 = HoleScore(holeNumber: i, grossScore: i == 15 ? 5 : 4)
        hs2.playerScore = score2
        score2.holeScores.append(hs2)
    }
    
    score1.updateTotalScores()
    score2.updateTotalScores()
    
    // Set winnings
    score1.winnings = 100.0
    score2.winnings = -100.0
    
    score1.round = round
    score2.round = round
    
    round.scores = [score1, score2]
    round.holesPlayed = 18
    
    // Insert all entities
    context.insert(course)
    context.insert(player1)
    context.insert(player2)
    context.insert(game)
    context.insert(round)
    context.insert(score1)
    context.insert(score2)
    
    try! context.save()
    
    return ScrollView {
        VStack(spacing: 20) {
            RoundStatusCard(round: round)
                .padding()
        }
    }
    .background(Color(UIColor.systemGroupedBackground))
    .modelContainer(container)
}

#Preview("Single Hole Round") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
        configurations: config
    )
    
    let context = container.mainContext
    
    // Create course with one hole
    let course = Course(name: "TPC Sawgrass", par: 72)
    let hole17 = Hole(number: 17, par: 3, handicap: 17, distance: 137)
    hole17.course = course
    course.holes.append(hole17)
    context.insert(hole17)
    
    // Create players
    let player1 = Player(name: "Scottie Scheffler", handicapIndex: 0.5)
    let player2 = Player(name: "Jon Rahm", handicapIndex: 1.2)
    let player3 = Player(name: "Patrick Cantlay", handicapIndex: 0.8)
    let player4 = Player(name: "Xander Schauffele", handicapIndex: 1.0)
    
    // Create game
    let game = Game(
        name: "Island Green Challenge",
        gameType: .skins,
        courseName: course.name,
        courseRating: 72.0,
        slopeRating: 155.0,
        par: 72
    )
    game.course = course
    game.players = [player1, player2, player3, player4]
    
    // Create single hole round (not completed)
    let round = Round(
        roundNumber: 1,
        holeNumber: 17,
        betAmount: 200.0,
        roundType: .hole
    )
    round.game = game
    round.isCompleted = false
    
    // Create scores (no hole scores yet - ready to start)
    let scores = [player1, player2, player3, player4].map { player in
        let score = PlayerScore(player: player)
        score.round = round
        return score
    }
    
    round.scores = scores
    
    // Insert all entities
    context.insert(course)
    context.insert(player1)
    context.insert(player2)
    context.insert(player3)
    context.insert(player4)
    context.insert(game)
    context.insert(round)
    scores.forEach { context.insert($0) }
    
    try! context.save()
    
    return ScrollView {
        VStack(spacing: 20) {
            RoundStatusCard(round: round)
                .padding()
        }
    }
    .background(Color(UIColor.systemGroupedBackground))
    .modelContainer(container)
}

#Preview("Front 9 - Just Started") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
        configurations: config
    )
    
    let context = container.mainContext
    
    // Create course
    let course = Course(name: "Bethpage Black", par: 71)
    
    // Create front 9 holes
    for i in 1...9 {
        let hole = Hole(
            number: i,
            par: [4, 4, 3, 5, 4, 4, 4, 3, 4][i-1],
            handicap: i * 2,
            distance: 400
        )
        hole.course = course
        course.holes.append(hole)
        context.insert(hole)
    }
    
    // Create players
    let player1 = Player(name: "Brooks Koepka", handicapIndex: 4.5)
    let player2 = Player(name: "Dustin Johnson", handicapIndex: 3.8)
    
    // Create game
    let game = Game(
        name: "Morning Nassau",
        gameType: .nassau,
        courseName: course.name,
        courseRating: 75.0,
        slopeRating: 148.0,
        par: 35
    )
    game.course = course
    game.players = [player1, player2]
    
    // Create front 9 round (just started, no scores)
    let round = Round(
        roundNumber: 1,
        betAmount: 25.0,
        roundType: .front9
    )
    round.game = game
    round.isCompleted = false
    
    // Create empty scores
    let score1 = PlayerScore(player: player1)
    let score2 = PlayerScore(player: player2)
    
    score1.round = round
    score2.round = round
    
    round.scores = [score1, score2]
    round.holesPlayed = 0
    
    // Insert all entities
    context.insert(course)
    context.insert(player1)
    context.insert(player2)
    context.insert(game)
    context.insert(round)
    context.insert(score1)
    context.insert(score2)
    
    try! context.save()
    
    return ScrollView {
        VStack(spacing: 20) {
            RoundStatusCard(round: round)
                .padding()
        }
    }
    .background(Color(UIColor.systemGroupedBackground))
    .modelContainer(container)
}

#Preview("Multiple Status Cards") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
        configurations: config
    )
    
    let context = container.mainContext
    
    // Create course
    let course = Course(name: "Torrey Pines", par: 72)
    for i in 1...18 {
        let hole = Hole(number: i, par: 4, handicap: i, distance: 400)
        hole.course = course
        course.holes.append(hole)
        context.insert(hole)
    }
    
    // Create players
    let player1 = Player(name: "Player One", handicapIndex: 10.0)
    let player2 = Player(name: "Player Two", handicapIndex: 15.0)
    
    // Create game
    let game = Game(
        name: "Tournament",
        gameType: .strokePlay,
        courseName: course.name,
        courseRating: 74.0,
        slopeRating: 140.0,
        par: 72
    )
    game.course = course
    game.players = [player1, player2]
    
    // Create multiple rounds in different states
    let rounds: [Round] = []
    
    // Round 1: Completed
    let round1 = Round(roundNumber: 1, betAmount: 20.0, roundType: .full18)
    round1.game = game
    round1.isCompleted = true
    round1.holesPlayed = 18
    
    let score1_1 = PlayerScore(player: player1)
    let score1_2 = PlayerScore(player: player2)
    for i in 1...18 {
        let hs1 = HoleScore(holeNumber: i, grossScore: 4)
        let hs2 = HoleScore(holeNumber: i, grossScore: 5)
        hs1.playerScore = score1_1
        hs2.playerScore = score1_2
        score1_1.holeScores.append(hs1)
        score1_2.holeScores.append(hs2)
    }
    score1_1.updateTotalScores()
    score1_2.updateTotalScores()
    score1_1.round = round1
    score1_2.round = round1
    round1.scores = [score1_1, score1_2]
    
    // Round 2: In progress
    let round2 = Round(roundNumber: 2, betAmount: 30.0, roundType: .full18)
    round2.game = game
    round2.isCompleted = false
    round2.holesPlayed = 12
    
    let score2_1 = PlayerScore(player: player1)
    let score2_2 = PlayerScore(player: player2)
    for i in 1...12 {
        let hs1 = HoleScore(holeNumber: i, grossScore: 4)
        let hs2 = HoleScore(holeNumber: i, grossScore: 4)
        hs1.playerScore = score2_1
        hs2.playerScore = score2_2
        score2_1.holeScores.append(hs1)
        score2_2.holeScores.append(hs2)
    }
    score2_1.updateTotalScores()
    score2_2.updateTotalScores()
    score2_1.round = round2
    score2_2.round = round2
    round2.scores = [score2_1, score2_2]
    
    // Round 3: Just started
    let round3 = Round(roundNumber: 3, betAmount: 40.0, roundType: .back9)
    round3.game = game
    round3.isCompleted = false
    round3.holesPlayed = 0
    
    let score3_1 = PlayerScore(player: player1)
    let score3_2 = PlayerScore(player: player2)
    score3_1.round = round3
    score3_2.round = round3
    round3.scores = [score3_1, score3_2]
    
    // Insert all entities
    context.insert(course)
    context.insert(player1)
    context.insert(player2)
    context.insert(game)
    context.insert(round1)
    context.insert(round2)
    context.insert(round3)
    context.insert(score1_1)
    context.insert(score1_2)
    context.insert(score2_1)
    context.insert(score2_2)
    context.insert(score3_1)
    context.insert(score3_2)
    
    try! context.save()
    
    return ScrollView {
        VStack(spacing: 16) {
            Text("Multiple Round Status Cards")
                .font(.headline)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Completed Round")
                    .font(.caption)
                    .foregroundColor(.secondary)
                RoundStatusCard(round: round1)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("In Progress (66% Complete)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                RoundStatusCard(round: round2)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Just Started")
                    .font(.caption)
                    .foregroundColor(.secondary)
                RoundStatusCard(round: round3)
            }
        }
        .padding()
    }
    .background(Color(UIColor.systemGroupedBackground))
    .modelContainer(container)
}
