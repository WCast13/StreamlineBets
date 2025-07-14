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
    
    // NEW: Add scorecard view model
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
                        // Scorecard toggle button
                        HStack {
                            Button(action: { withAnimation { showingScorecard.toggle() } }) {
                                Label(
                                    showingScorecard ? "Hide Scorecard" : "Show Scorecard",
                                    systemImage: showingScorecard ? "chevron.up" : "chevron.down"
                                )
                                .font(.caption)
                                .foregroundColor(.accentColor)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                            
                            Spacer()
                        }
                        .background(Color(UIColor.secondarySystemBackground))
                        
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
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(6)
                        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                    .background(Color(UIColor.secondarySystemBackground))
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Main scoring content
                ScrollView {
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
                        
                        // Game Status (if enabled)
                        if showingGameStatus, let gameType = round.game?.gameType {
                            GameStatusView(round: round)
                                .padding(.horizontal)
                                .padding(.bottom)
                                .transition(.opacity)
                        }
                        
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { withAnimation { showingGameStatus.toggle() } }) {
                        Image(systemName: showingGameStatus ? "info.circle.fill" : "info.circle")
                            .foregroundColor(.accentColor)
                    }
                }
                
                // Scorecard toggle in toolbar
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { withAnimation { showingScorecard.toggle() } }) {
                        Image(systemName: showingScorecard ? "table" : "table.fill")
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
