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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Bindable var round: Round
    
    @State private var currentHole: Int = 1
    @State private var scores: [UUID: Int] = [:]
    @State private var showingRoundComplete = false
    @State private var showingExitConfirmation = false
    @State private var showingScorecard = true
    @State private var showingGameStatus = true
    
    // NEW: Add scorecard view model as State
    @State private var scorecardViewModel: ScorecardViewModel
    
    // NEW: Initialize with round
    init(round: Round) {
        self.round = round
        self._scorecardViewModel = State(wrappedValue: ScorecardViewModel(round: round))
    }
    
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
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // UPDATED: New scorecard implementation
                if showingScorecard {
                    VStack(spacing: 0) {
                        
                        // New scorecard components
                        VStack(spacing: 0) {
                            ScorecardHeader(
                                viewModel: scorecardViewModel,
                                isCompact: isCompact
                            )
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                ScorecardGrid(
                                    viewModel: scorecardViewModel,
                                    currentHoleNumber: currentHoleNumber,
                                    scores: $scores,
                                    isEditable: false, // Set to false since we have dedicated score entry UI below
                                    onScoreTap: nil
                                )
                            }
                            
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Scorecard toggle button
                Button(action: { withAnimation { showingScorecard.toggle() } }) {
                                    Label(
                                        showingScorecard ? "Hide Scorecard" : "Show Scorecard",
                                        systemImage: showingScorecard ? "chevron.up" : "chevron.down"
                                    )
                                    .font(.caption)
                                    .foregroundColor(.accentColor)
                                }
                                .padding(.bottom)
                // Main scoring content
                ScrollView {
                    VStack(spacing: 0) {
                        // Top Section - Hole Info
                        VStack(spacing: 16) {
                            CompactHoleInfoView(currentHole: currentHole, totalHoles: totalHoles, holeNumber: currentHoleNumber, hole: currentHoleInfo)
                        }
                        .padding()
                        
                        Spacer(minLength: 0)
                        
                        // Scrollable Player Score Entry
                        VStack(spacing: 16) {
                            ForEach(round.scores.sorted(by: {
                                ($0.player?.name ?? "") < ($1.player?.name ?? "")
                            })) { playerScore in
                                LiveScoreCard(
                                    playerScore: playerScore,
                                    score: binding(for: playerScore.id),
                                    holeInfo: currentHoleInfo,
                                    courseHandicap: courseHandicap(for: playerScore.player),
                                    gameType: round.game?.gameType ?? .strokePlay,
                                    allScores: round.scores
                                )
                            }
                        }
                        .padding()
                        
                        // Bottom Navigation
                        VStack(spacing: 12) {
                            // Quick Score Buttons for Common Scores
                            
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
                                .controlSize(.small)
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
                                .controlSize(.small)
                                .disabled(!allScoresEntered)
                            }
                        }
                        .padding()
                    }
                }
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
                
                // Scorecard toggle in toolbar
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { withAnimation { showingScorecard.toggle() } }) {
                        Image(systemName: showingScorecard ? "table.fill" : "table")
                            .foregroundColor(.accentColor)
                    }
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
            GameScoringCalculator.calculateSkinsWinnings(for: round)
        case .nassau:
            GameScoringCalculator.calculateNassauWinnings(for: round)
        case .matchPlay:
            GameScoringCalculator.calculateMatchPlayWinnings(for: round)
        case .wolf:
            GameScoringCalculator.calculateWolfWinnings(for: round)
        case .bestBall:
            GameScoringCalculator.calculateBestBallWinnings(for: round)
        case .strokePlay:
            GameScoringCalculator.calculateStrokePlayWinnings(for: round)
        case .scramble:
            GameScoringCalculator.calculateScrambleWinnings(for: round)
        case .custom:
            GameScoringCalculator.calculateStrokePlayWinnings(for: round)
        }
    }
}

// MARK: - Preview
#Preview("Live Scoring - Stroke Play") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
        configurations: config
    )
    
    let context = container.mainContext
    
    // Create course
    let course = Course(name: "Pine Valley Golf Club", par: 70)
    
    // Create holes with realistic data
    let holeData: [(par: Int, handicap: Int, distance: Int)] = [
        (4, 11, 428),  // Hole 1
        (4, 5, 367),   // Hole 2
        (3, 17, 185),  // Hole 3
        (4, 3, 461),   // Hole 4
        (3, 15, 226),  // Hole 5
        (4, 1, 391),   // Hole 6
        (5, 13, 585),  // Hole 7
        (4, 9, 327),   // Hole 8
        (4, 7, 432),   // Hole 9
        (3, 16, 145),  // Hole 10
        (4, 8, 399),   // Hole 11
        (4, 2, 382),   // Hole 12
        (3, 18, 185),  // Hole 13
        (4, 10, 448),  // Hole 14
        (5, 12, 603),  // Hole 15
        (4, 4, 436),   // Hole 16
        (4, 6, 388),   // Hole 17
        (4, 14, 424)   // Hole 18
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
    
    // Create tees
    let whiteTees = Tee(
        name: "White",
        menRating: 69.3,
        menSlope: 129,
        womenRating: 74.0,
        womenSlope: 139
    )
    whiteTees.course = course
    course.tees.append(whiteTees)
    
    // Create players
    let player1 = Player(name: "John Smith", handicapIndex: 12.3)
    let player2 = Player(name: "Mike Johnson", handicapIndex: 8.7)
    let player3 = Player(name: "Sarah Williams", handicapIndex: 15.2)
    
    // Create game
    let game = Game(
        name: "Weekend Round",
        gameType: .strokePlay,
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
    
    // Add some existing hole scores (first 3 holes)
    for i in 1...3 {
        let hs1 = HoleScore(holeNumber: i, grossScore: i == 1 ? 5 : 4)
        hs1.playerScore = score1
        hs1.hole = course.holes[i-1]
        score1.holeScores.append(hs1)
        
        let hs2 = HoleScore(holeNumber: i, grossScore: i == 2 ? 3 : 4)
        hs2.playerScore = score2
        hs2.hole = course.holes[i-1]
        score2.holeScores.append(hs2)
        
        let hs3 = HoleScore(holeNumber: i, grossScore: i == 3 ? 6 : 5)
        hs3.playerScore = score3
        hs3.hole = course.holes[i-1]
        score3.holeScores.append(hs3)
    }
    
    round.scores = [score1, score2, score3]
    round.holesPlayed = 3
    
    // Insert all entities
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
    
    try! context.save()
    
    return LiveScoringView(round: round)
        .modelContainer(container)
}

#Preview("Live Scoring - Match Play") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
        configurations: config
    )
    
    let context = container.mainContext
    
    // Create course
    let course = Course(name: "St. Andrews Old Course", par: 72)
    
    // Create simplified holes
    for i in 1...18 {
        let hole = Hole(
            number: i,
            par: [4, 4, 4, 4, 5, 4, 4, 3, 4, 4, 3, 4, 4, 5, 4, 4, 4, 4][i-1],
            handicap: [4, 8, 12, 10, 2, 14, 6, 16, 18, 7, 15, 13, 3, 5, 1, 11, 9, 17][i-1],
            distance: 400
        )
        hole.course = course
        course.holes.append(hole)
        context.insert(hole)
    }
    
    // Create players
    let player1 = Player(name: "Tiger Woods", handicapIndex: 0.0)
    let player2 = Player(name: "Phil Mickelson", handicapIndex: 2.4)
    
    // Create match play game
    let game = Game(
        name: "Match Play Challenge",
        gameType: .matchPlay,
        courseName: course.name,
        courseRating: 72.0,
        slopeRating: 134.0,
        par: 72
    )
    game.course = course
    game.players = [player1, player2]
    
    // Create round
    let round = Round(
        roundNumber: 1,
        betAmount: 100.0,
        roundType: .full18
    )
    round.game = game
    
    // Create player scores
    let score1 = PlayerScore(player: player1)
    score1.round = round
    let score2 = PlayerScore(player: player2)
    score2.round = round
    
    // Add some match play scores (first 5 holes)
    let matchPlayScores = [
        (1, 4, 5),  // Tiger wins
        (2, 4, 4),  // Halved
        (3, 3, 4),  // Tiger wins
        (4, 5, 4),  // Phil wins
        (5, 4, 6),  // Tiger wins
    ]
    
    for (hole, tigerScore, philScore) in matchPlayScores {
        let hs1 = HoleScore(holeNumber: hole, grossScore: tigerScore)
        hs1.playerScore = score1
        hs1.hole = course.holes[hole-1]
        score1.holeScores.append(hs1)
        
        let hs2 = HoleScore(holeNumber: hole, grossScore: philScore)
        hs2.playerScore = score2
        hs2.hole = course.holes[hole-1]
        score2.holeScores.append(hs2)
    }
    
    round.scores = [score1, score2]
    round.holesPlayed = 5
    
    // Insert all entities
    context.insert(course)
    context.insert(player1)
    context.insert(player2)
    context.insert(game)
    context.insert(round)
    context.insert(score1)
    context.insert(score2)
    
    try! context.save()
    
    return LiveScoringView(round: round)
        .modelContainer(container)
}

#Preview("Live Scoring - Skins Game") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
        configurations: config
    )
    
    let context = container.mainContext
    
    // Create course
    let course = Course(name: "TPC Sawgrass", par: 72)
    
    // Create first 9 holes for Front 9 round
    for i in 1...9 {
        let hole = Hole(
            number: i,
            par: [4, 5, 3, 4, 4, 4, 4, 3, 5][i-1],
            handicap: [9, 3, 17, 11, 1, 15, 5, 13, 7][i-1],
            distance: [400, 532, 177, 384, 471, 393, 442, 237, 583][i-1]
        )
        hole.course = course
        course.holes.append(hole)
        context.insert(hole)
    }
    
    // Create players
    let player1 = Player(name: "Jordan Spieth", handicapIndex: 3.2)
    let player2 = Player(name: "Justin Thomas", handicapIndex: 1.8)
    let player3 = Player(name: "Rickie Fowler", handicapIndex: 4.5)
    let player4 = Player(name: "Jason Day", handicapIndex: 2.1)
    
    // Create skins game
    let game = Game(
        name: "Sunday Skins",
        gameType: .skins,
        courseName: course.name,
        courseRating: 72.0,
        slopeRating: 135.0,
        par: 36 // Front 9 only
    )
    game.course = course
    game.players = [player1, player2, player3, player4]
    
    // Create round (Front 9 only)
    let round = Round(
        roundNumber: 1,
        betAmount: 50.0,
        roundType: .front9
    )
    round.game = game
    
    // Create player scores
    let scores = [player1, player2, player3, player4].map { player in
        let score = PlayerScore(player: player)
        score.round = round
        return score
    }
    
    // Add some skins game scores (first 2 holes)
    // Hole 1: Tie (carry over)
    for (index, score) in scores.enumerated() {
        let hs = HoleScore(holeNumber: 1, grossScore: 4)
        hs.playerScore = score
        hs.hole = course.holes[0]
        score.holeScores.append(hs)
    }
    
    // Hole 2: Player 2 wins
    let hole2Scores = [5, 4, 5, 6]
    for (index, score) in scores.enumerated() {
        let hs = HoleScore(holeNumber: 2, grossScore: hole2Scores[index])
        hs.playerScore = score
        hs.hole = course.holes[1]
        score.holeScores.append(hs)
    }
    
    round.scores = scores
    round.holesPlayed = 2
    
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
    
    return LiveScoringView(round: round)
        .modelContainer(container)
}

#Preview("Live Scoring - Single Hole") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
        configurations: config
    )
    
    let context = container.mainContext
    
    // Create course with just one hole
    let course = Course(name: "Local Country Club", par: 72)
    
    let hole17 = Hole(
        number: 17,
        par: 3,
        handicap: 15,
        distance: 208
    )
    hole17.course = course
    course.holes.append(hole17)
    context.insert(hole17)
    
    // Create players
    let player1 = Player(name: "Amateur A", handicapIndex: 18.5)
    let player2 = Player(name: "Amateur B", handicapIndex: 22.3)
    
    // Create single hole game
    let game = Game(
        name: "Closest to Pin",
        gameType: .skins,
        courseName: course.name,
        courseRating: 72.0,
        slopeRating: 125.0,
        par: 72
    )
    game.course = course
    game.players = [player1, player2]
    
    // Create round for single hole
    let round = Round(
        roundNumber: 1,
        holeNumber: 17,
        betAmount: 10.0,
        roundType: .hole
    )
    round.game = game
    
    // Create player scores (no existing scores yet)
    let score1 = PlayerScore(player: player1)
    score1.round = round
    let score2 = PlayerScore(player: player2)
    score2.round = round
    
    round.scores = [score1, score2]
    
    // Insert all entities
    context.insert(course)
    context.insert(player1)
    context.insert(player2)
    context.insert(game)
    context.insert(round)
    context.insert(score1)
    context.insert(score2)
    
    try! context.save()
    
    return LiveScoringView(round: round)
        .modelContainer(container)
}

