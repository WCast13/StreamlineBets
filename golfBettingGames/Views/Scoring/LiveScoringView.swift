//
//  LiveScoringView.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/7/25.
//

import SwiftUI
import SwiftData

struct LiveScoringView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var round: Round
    
    @State private var currentHole: Int = 1
    @State private var scores: [UUID: Int] = [:]
    @State private var showingRoundComplete = false
    @State private var showingExitConfirmation = false
    
    private var course: Course? { round.game?.course }
    private var totalHoles: Int {
        switch round.roundType {
        case .front9: return 9
        case .back9: return 9
        case .full18: return 18
        case .hole: return 1
        case .custom: return round.holesPlayed
        }
    }
    
    private var startingHole: Int {
        switch round.roundType {
        case .back9: return 10
        case .hole: return round.holeNumber ?? 1
        default: return 1
        }
    }
    
    private var currentHoleNumber: Int {
        startingHole + currentHole - 1
    }
    
    private var currentHoleInfo: Hole? {
        course?.holes.first(where: { $0.number == currentHoleNumber })
    }
    
    private var allScoresEntered: Bool {
        round.scores.allSatisfy { playerScore in
            scores[playerScore.id] != nil && scores[playerScore.id]! > 0
        }
    }
    
    private var isLastHole: Bool {
        currentHole == totalHoles
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top Section - Hole Info
                VStack(spacing: 16) {
                    // Hole Progress Indicator
                    HoleProgressView(
                        currentHole: currentHole,
                        totalHoles: totalHoles,
                        holeNumber: currentHoleNumber
                    )
                    
                    // Hole Details
                    if let hole = currentHoleInfo {
                        HoleInfoCard(hole: hole)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                
                // Scrollable Player Score Entry
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(round.scores.sorted(by: {
                            ($0.player?.name ?? "") < ($1.player?.name ?? "")
                        })) { playerScore in
                            LiveScoreCard(
                                playerScore: playerScore,
                                score: binding(for: playerScore.id),
                                holeInfo: currentHoleInfo,
                                courseHandicap: courseHandicap(for: playerScore.player)
                            )
                        }
                    }
                    .padding()
                }
                
                // Bottom Navigation
                VStack(spacing: 12) {
                    // Quick Score Buttons for Common Scores
                    if allScoresEntered {
                        HStack {
                            Text("All scores entered")
                                .font(.caption)
                                .foregroundColor(.green)
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .imageScale(.small)
                        }
                        .padding(.top, 8)
                    }
                    
                    HStack(spacing: 16) {
                        // Previous Hole
                        Button(action: previousHole) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Previous")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .disabled(currentHole == 1)
                        
                        // Next Hole or Finish
                        Button(action: nextHoleOrFinish) {
                            HStack {
                                Text(isLastHole ? "Finish Round" : "Next Hole")
                                Image(systemName: isLastHole ? "checkmark.circle.fill" : "chevron.right")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!allScoresEntered)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
            }
            .navigationTitle("Live Scoring")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Exit") {
                        showingExitConfirmation = true
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("Round \(round.roundNumber)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .onAppear {
            setupInitialHole()
            loadExistingScores()
        }
        .alert("Exit Scoring?", isPresented: $showingExitConfirmation) {
            Button("Save & Exit", role: .destructive) {
                saveCurrentScores()
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Your scores will be saved. You can continue scoring later.")
        }
        .alert("Round Complete!", isPresented: $showingRoundComplete) {
            Button("View Results") {
                saveCurrentScores()
                completeRound()
                dismiss()
            }
        } message: {
            Text("All holes have been scored. Ready to calculate results?")
        }
    }
    
    // MARK: - Helper Methods
    
    private func binding(for playerId: UUID) -> Binding<Int> {
        Binding(
            get: { scores[playerId] ?? 0 },
            set: { scores[playerId] = $0 }
        )
    }
    
    private func courseHandicap(for player: Player?) -> Int {
        guard let player = player, let game = round.game else { return 0 }
        return player.courseHandicap(
            courseRating: game.effectiveRating,
            slopeRating: Double(game.effectiveSlope),
            par: game.par
        )
    }
    
    private func setupInitialHole() {
        if round.roundType == .hole {
            currentHole = 1
        } else {
            // Find the first unscored hole
            for hole in 1...totalHoles {
                let holeNum = startingHole + hole - 1
                let hasScores = round.scores.allSatisfy { playerScore in
                    playerScore.holeScores.contains { $0.holeNumber == holeNum }
                }
                if !hasScores {
                    currentHole = hole
                    break
                }
            }
        }
    }
    
    private func loadExistingScores() {
        scores.removeAll()
        let defaultScore = currentHoleInfo?.par ?? 4 // Default to par 4 if no hole info
        
        for playerScore in round.scores {
            if let holeScore = playerScore.holeScores.first(where: { $0.holeNumber == currentHoleNumber }) {
                scores[playerScore.id] = holeScore.grossScore
            } else {
                // Initialize to par if no existing score
                scores[playerScore.id] = defaultScore
            }
        }
    }
    
    private func saveCurrentScores() {
        for playerScore in round.scores {
            guard let score = scores[playerScore.id], score > 0 else { continue }
            
            if let existingScore = playerScore.holeScores.first(where: { $0.holeNumber == currentHoleNumber }) {
                existingScore.grossScore = score
            } else {
                let holeScore = HoleScore(
                    holeNumber: currentHoleNumber,
                    grossScore: score
                )
                holeScore.playerScore = playerScore
                holeScore.hole = currentHoleInfo
                playerScore.holeScores.append(holeScore)
                modelContext.insert(holeScore)
            }
        }
        
        round.holesPlayed = max(round.holesPlayed, currentHole)
        try? modelContext.save()
    }
    
    private func previousHole() {
        saveCurrentScores()
        currentHole = max(1, currentHole - 1)
        loadExistingScores()
    }
    
    private func nextHoleOrFinish() {
        saveCurrentScores()
        
        if isLastHole {
            showingRoundComplete = true
        } else {
            currentHole += 1
            scores.removeAll()
            loadExistingScores()
        }
    }
    
    private func completeRound() {
        // Update total scores
        for playerScore in round.scores {
            playerScore.updateTotalScores()
        }
        
        // Calculate winnings based on game type
        calculateWinnings()
        
        round.isCompleted = true
        try? modelContext.save()
    }
    
    private func calculateWinnings() {
        guard let game = round.game else { return }
        
        switch game.gameType {
        case .skins:
            calculateSkinsWinnings()  // ✅ Uses your existing method
        case .nassau:
            GameScoringCalculator.calculateNassauWinnings(for: round)  // ✅ Now supported
        case .matchPlay:
            GameScoringCalculator.calculateMatchPlayWinnings(for: round)  // ✅ Now supported
        case .wolf:
            GameScoringCalculator.calculateWolfWinnings(for: round)  // ✅ Now supported
        case .bestBall:
            GameScoringCalculator.calculateBestBallWinnings(for: round)  // ✅ Now supported
        case .strokePlay:
            GameScoringCalculator.calculateStrokePlayWinnings(for: round)  // ✅ Now supported
        case .scramble:
            GameScoringCalculator.calculateStrokePlayWinnings(for: round)  // ✅ Now supported
        case .custom:
            GameScoringCalculator.calculateStrokePlayWinnings(for: round)  // ✅ Now supported
        }
    }
    
    private func calculateSkinsWinnings() {
        // For hole-by-hole skins
        if round.roundType == .hole {
            let scores = round.scores
            guard !scores.isEmpty else { return }
            
            let lowestNetScore = scores.map { $0.netScore }.min() ?? 0
            let winners = scores.filter { $0.netScore == lowestNetScore }
            
            if winners.count == 1 {
                let totalPot = round.betAmount * Double(scores.count)
                for score in scores {
                    if score.netScore == lowestNetScore {
                        score.winnings = totalPot - round.betAmount
                    } else {
                        score.winnings = -round.betAmount
                    }
                }
            } else {
                // Tie - no money changes hands
                for score in scores {
                    score.winnings = 0
                }
            }
        } else {
            // Multi-hole skins - calculate per hole
            // This would be more complex, calculating skins for each hole
            calculateStrokePlayWinnings()
        }
    }
    
    private func calculateNassauWinnings() {
        // Nassau: Front 9, Back 9, and Total
        // Simplified for now
        calculateStrokePlayWinnings()
    }
    
    private func calculateMatchPlayWinnings() {
        // Match play hole by hole
        calculateStrokePlayWinnings()
    }
    
    private func calculateStrokePlayWinnings() {
        let scores = round.scores.sorted { $0.netScore < $1.netScore }
        guard scores.count >= 2 else { return }
        
        let winner = scores[0]
        let totalPot = round.betAmount * Double(scores.count)
        
        // Winner takes all
        winner.winnings = totalPot - round.betAmount
        for score in scores.dropFirst() {
            score.winnings = -round.betAmount
        }
    }
}

// Add this to the bottom of LiveScoringView.swift file

#Preview {
    // Create a preview container with mock data
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
        configurations: config
    )
    
    let context = container.mainContext
    
    // Create mock course
    let course = Course(name: "Pebble Beach Golf Links", par: 72, city: "Pebble Beach", state: "CA")
    
    // Create tees
    let whiteTees = Tee(
        name: "White",
        menRating: 71.7,
        menSlope: 133,
        womenRating: 74.0,
        womenSlope: 140
    )
    whiteTees.course = course
    course.tees.append(whiteTees)
    
    // Create holes with realistic data
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
    
    // Create players
    let player1 = Player(name: "Tiger Woods", handicapIndex: 2.5)
    let player2 = Player(name: "Phil Mickelson", handicapIndex: 5.3)
    let player3 = Player(name: "Rory McIlroy", handicapIndex: 0.8)
    
    // Create game
    let game = Game(
        name: "Sunday Skins",
        gameType: .skins,
        courseName: course.name,
        courseRating: whiteTees.menRating,
        slopeRating: Double(whiteTees.menSlope),
        par: course.par
    )
    game.course = course
    game.selectedTee = whiteTees
    game.selectedGender = .men
    game.players = [player1, player2, player3]
    
    // Create round
    let round = Round(
        roundNumber: 1,
        betAmount: 50.0,
        roundType: .full18,
        startingHole: 1
    )
    round.game = game
    
    // Create player scores
    let score1 = PlayerScore(player: player1)
    score1.round = round
    
    let score2 = PlayerScore(player: player2)
    score2.round = round
    
    let score3 = PlayerScore(player: player3)
    score3.round = round
    
    // Add some existing hole scores to show progress
    // Simulate first 3 holes already scored
    for holeNum in 1...3 {
        let hole = course.holes.first(where: { $0.number == holeNum })
        
        let holeScore1 = HoleScore(holeNumber: holeNum, grossScore: 4)
        holeScore1.playerScore = score1
        holeScore1.hole = hole
        score1.holeScores.append(holeScore1)
        
        let holeScore2 = HoleScore(holeNumber: holeNum, grossScore: 5)
        holeScore2.playerScore = score2
        holeScore2.hole = hole
        score2.holeScores.append(holeScore2)
        
        let holeScore3 = HoleScore(holeNumber: holeNum, grossScore: 3)
        holeScore3.playerScore = score3
        holeScore3.hole = hole
        score3.holeScores.append(holeScore3)
    }
    
    round.scores = [score1, score2, score3]
    round.holesPlayed = 3
    
    // Insert all objects
    context.insert(course)
    context.insert(whiteTees)
    context.insert(player1)
    context.insert(player2)
    context.insert(player3)
    context.insert(game)
    context.insert(round)
    context.insert(score1)
    context.insert(score2)
    context.insert(score3)
    
    // Save context
    try! context.save()
    
    return NavigationStack {
        LiveScoringView(round: round)
    }
    .modelContainer(container)
}

// Additional preview showing hole-by-hole scoring
#Preview("Single Hole") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
        configurations: config
    )
    
    let context = container.mainContext
    
    // Create simple course
    let course = Course(name: "Local Golf Club", par: 72)
    
    // Create single hole
    let hole = Hole(number: 7, par: 3, handicap: 15, distance: 165)
    hole.course = course
    course.holes.append(hole)
    
    // Create players
    let player1 = Player(name: "John Smith", handicapIndex: 12.5)
    let player2 = Player(name: "Mike Johnson", handicapIndex: 18.2)
    
    // Create game
    let game = Game(
        name: "Hole 7 Skins",
        gameType: .skins,
        courseName: course.name,
        courseRating: 72.0,
        slopeRating: 113.0,
        par: 72
    )
    game.course = course
    game.players = [player1, player2]
    
    // Create single hole round
    let round = Round(
        roundNumber: 5,
        holeNumber: 7,
        betAmount: 20.0,
        roundType: .hole
    )
    round.game = game
    
    // Create player scores
    let score1 = PlayerScore(player: player1)
    score1.round = round
    
    let score2 = PlayerScore(player: player2)
    score2.round = round
    
    round.scores = [score1, score2]
    
    // Insert all
    context.insert(course)
    context.insert(hole)
    context.insert(player1)
    context.insert(player2)
    context.insert(game)
    context.insert(round)
    context.insert(score1)
    context.insert(score2)
    
    try! context.save()
    
    return NavigationStack {
        LiveScoringView(round: round)
    }
    .modelContainer(container)
}

// Preview showing back 9 scoring
#Preview("Back 9") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
        configurations: config
    )
    
    let context = container.mainContext
    
    // Create course with back 9 holes
    let course = Course(name: "Country Club", par: 72)
    
    // Create back 9 holes
    for holeNum in 10...18 {
        let par = holeNum == 12 || holeNum == 17 ? 3 : (holeNum == 14 || holeNum == 18 ? 5 : 4)
        let hole = Hole(
            number: holeNum,
            par: par,
            handicap: (holeNum - 9) * 2,
            distance: par == 3 ? 180 : (par == 5 ? 520 : 400)
        )
        hole.course = course
        course.holes.append(hole)
        context.insert(hole)
    }
    
    // Create players
    let player1 = Player(name: "Player One", handicapIndex: 8.5)
    let player2 = Player(name: "Player Two", handicapIndex: 15.0)
    
    // Create game
    let game = Game(
        name: "Back 9 Nassau",
        gameType: .nassau,
        courseName: course.name,
        courseRating: 72.0,
        slopeRating: 128.0,
        par: 72
    )
    game.course = course
    game.players = [player1, player2]
    
    // Create back 9 round
    let round = Round(
        roundNumber: 2,
        betAmount: 30.0,
        roundType: .back9,
        startingHole: 10
    )
    round.game = game
    
    // Create player scores
    let score1 = PlayerScore(player: player1)
    score1.round = round
    
    let score2 = PlayerScore(player: player2)
    score2.round = round
    
    round.scores = [score1, score2]
    
    // Insert all
    context.insert(course)
    context.insert(player1)
    context.insert(player2)
    context.insert(game)
    context.insert(round)
    context.insert(score1)
    context.insert(score2)
    
    try! context.save()
    
    return NavigationStack {
        LiveScoringView(round: round)
    }
    .modelContainer(container)
}
