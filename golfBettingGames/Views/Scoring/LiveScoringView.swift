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
        for playerScore in round.scores {
            if let holeScore = playerScore.holeScores.first(where: { $0.holeNumber == currentHoleNumber }) {
                scores[playerScore.id] = holeScore.grossScore
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
