//
//  GameHeaderView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/20/25.
//

import SwiftUI
import SwiftData

// MARK: - GameHeaderView.swift
struct GameHeaderView: View {
    let game: Game
    
    var body: some View {
        VStack(spacing: 8) {
            Text(game.courseName)
                .font(.headline)
            
            HStack(spacing: 20) {
                Label(game.gameType.description, systemImage: "flag.fill")
                Label("\(game.players.count) Players", systemImage: "person.2.fill")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
    }
}


// MARK: - StandingRow.swift
struct StandingRow: View {
    let player: Player
    let amount: Double
    let rank: Int
    
    private var rankEmoji: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return ""
        }
    }
    
    var body: some View {
        HStack {
            if !rankEmoji.isEmpty {
                Text(rankEmoji)
                    .font(.title3)
            }
            
            Text(player.name)
                .font(.subheadline)
                .fontWeight(rank == 1 ? .semibold : .regular)
            
            Spacer()
            
            Text(formatCurrency(amount))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(amount >= 0 ? .green : .red)
        }
        .padding(.vertical, 4)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}



// MARK: - ActiveRoundCard.swift
struct ActiveRoundCard: View {
    @Bindable var round: Round
    let onTap: () -> Void
    
    private var scoresEntered: Int {
        round.scores.filter { $0.score > 0 }.count
    }
    
    private var totalScores: Int {
        round.scores.count
    }
    
    private var progress: Double {
        guard totalScores > 0 else { return 0 }
        return Double(scoresEntered) / Double(totalScores)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Round Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Round \(round.roundNumber)")
                            .font(.headline)
                        
                        if let holeNumber = round.holeNumber {
                            Text("Hole \(holeNumber)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("$\(round.betAmount, specifier: "%.0f")")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                        
                        Text("\(scoresEntered)/\(totalScores) scored")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(progress == 1.0 ? Color.green : Color.accentColor)
                            .frame(width: geometry.size.width * progress, height: 8)
                            .cornerRadius(4)
                            .animation(.easeInOut, value: progress)
                    }
                }
                .frame(height: 8)
                
                // Quick Score Entry
                if scoresEntered < totalScores {
                    Text("Tap to enter scores")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                } else {
                    Text("All scores entered ✓")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - EmptyRoundsView.swift
struct EmptyRoundsView: View {
    @Binding var showingNewRound: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "flag.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Active Rounds")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Start a new round to begin scoring")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: { showingNewRound = true }) {
                Label("New Round", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(25)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - LiveScoringActions.swift
struct LiveScoringActions: View {
    @Binding var showingNewRound: Bool
    @Binding var showingGameSummary: Bool
    @Binding var showingEndGameAlert: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: { showingNewRound = true }) {
                Label("New Round", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            
            Button(action: { showingEndGameAlert = true }) {
                Label("End Game", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
    }
}

// MARK: - QuickScoreEntry.swift
struct QuickScoreEntry: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var round: Round
    @State private var scores: [UUID: Int] = [:]
    @State private var currentPlayerIndex = 0
    
    private var sortedScores: [PlayerScore] {
        round.scores.sorted {
            ($0.player?.name ?? "") < ($1.player?.name ?? "")
        }
    }
    
    private var currentScore: PlayerScore? {
        guard currentPlayerIndex < sortedScores.count else { return nil }
        return sortedScores[currentPlayerIndex]
    }
    
    private var isLastPlayer: Bool {
        currentPlayerIndex >= sortedScores.count - 1
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress Indicator
                ProgressIndicator(
                    current: currentPlayerIndex + 1,
                    total: sortedScores.count
                )
                
                Spacer()
                
                // Current Player
                if let score = currentScore {
                    CurrentPlayerView(
                        score: score,
                        round: round,
                        enteredScore: scores[score.id] ?? score.score
                    )
                    
                    // Score Entry Buttons
                    ScoreButtonGrid(
                        selectedScore: Binding(
                            get: { scores[score.id] ?? score.score },
                            set: { scores[score.id] = $0 }
                        )
                    )
                    .padding()
                }
                
                Spacer()
                
                // Navigation Buttons
                HStack(spacing: 16) {
                    Button(action: previousPlayer) {
                        Label("Previous", systemImage: "arrow.left")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.secondary.opacity(0.2))
                            .cornerRadius(12)
                    }
                    .disabled(currentPlayerIndex == 0)
                    
                    Button(action: nextPlayer) {
                        Label(isLastPlayer ? "Finish" : "Next",
                              systemImage: isLastPlayer ? "checkmark" : "arrow.right")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Enter Scores")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveScores() }
                        .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            initializeScores()
        }
    }
    
    private func initializeScores() {
        for score in round.scores {
            if score.score > 0 {
                scores[score.id] = score.score
            }
        }
    }
    
    private func previousPlayer() {
        if currentPlayerIndex > 0 {
            currentPlayerIndex -= 1
        }
    }
    
    private func nextPlayer() {
        if isLastPlayer {
            saveScores()
        } else {
            currentPlayerIndex += 1
        }
    }
    
    private func saveScores() {
        // Update all scores
        for score in round.scores {
            if let enteredScore = scores[score.id], enteredScore > 0 {
                score.score = enteredScore
                
                // Calculate net score
                if let player = score.player,
                   let game = round.game {
                    
                    let courseHandicap = player.courseHandicap(
                        courseRating: game.effectiveRating,
                        slopeRating: Double(game.effectiveSlope),
                        par: game.par
                    )
                    
                    // For single hole, calculate strokes
                    let strokesForHole: Int
                    if round.roundType == .hole, let holeNumber = round.holeNumber {
                        strokesForHole = courseHandicap >= holeNumber ? 1 : 0
                    } else {
                        strokesForHole = 0
                    }
                    
                    score.netScore = enteredScore - strokesForHole
                }
            }
        }
        
        // Check if all scores are entered
        let allScoresEntered = round.scores.allSatisfy { $0.score > 0 }
        if allScoresEntered {
            calculateWinnings()
            round.isCompleted = true
        }
        
        try? modelContext.save()
        dismiss()
    }
    
    private func calculateWinnings() {
        guard let game = round.game else { return }
        
        // Simple skins calculation
        if game.gameType == .skins {
            let scores = round.scores
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
                // Tie - no winner
                for score in scores {
                    score.winnings = 0
                }
            }
        }
    }
}

// MARK: - ProgressIndicator.swift
struct ProgressIndicator: View {
    let current: Int
    let total: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...total, id: \.self) { index in
                Circle()
                    .fill(index <= current ? Color.accentColor : Color.secondary.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
        .padding()
    }
}

// MARK: - CurrentPlayerView.swift
struct CurrentPlayerView: View {
    let score: PlayerScore
    let round: Round
    let enteredScore: Int
    
    private var courseHandicap: Int {
        guard let player = score.player,
              let game = round.game else { return 0 }
        
        return player.courseHandicap(
            courseRating: game.courseRating,
            slopeRating: game.slopeRating,
            par: game.par
        )
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text(score.player?.name ?? "Unknown")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if let holeNumber = round.holeNumber {
                Text("Hole \(holeNumber)")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            Text("Handicap: \(courseHandicap)")
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(20)
            
            if enteredScore > 0 {
                Text("\(enteredScore)")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.accentColor)
            } else {
                Text("Select Score")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

// MARK: - ScoreButtonGrid.swift
struct ScoreButtonGrid: View {
    @Binding var selectedScore: Int
    
    let scores = Array(1...12)
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(scores, id: \.self) { score in
                ScoreButton(
                    score: score,
                    isSelected: selectedScore == score
                ) {
                    selectedScore = score
                }
            }
        }
    }
}

// MARK: - ScoreButton.swift
struct ScoreButton: View {
    let score: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(score)")
                .font(.title)
                .fontWeight(.semibold)
                .frame(width: 70, height: 70)
                .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(35)
        }
    }
}

// MARK: - GameSummaryView.swift
struct GameSummaryView: View {
    @Environment(\.dismiss) private var dismiss
    let game: Game
    
    var body: some View {
        NavigationStack {
            List {
                Section("Game Information") {
                    LabeledContent("Course", value: game.courseName)
                    LabeledContent("Type", value: game.gameType.description)
                    LabeledContent("Total Rounds", value: "\(game.rounds.count)")
                }
                
                Section("Final Standings") {
                    ForEach(game.players.sorted {
                        game.totalForPlayer($0) > game.totalForPlayer($1)
                    }) { player in
                        HStack {
                            Text(player.name)
                            Spacer()
                            Text(formatCurrency(game.totalForPlayer(player)))
                                .fontWeight(.medium)
                                .foregroundColor(game.totalForPlayer(player) >= 0 ? .green : .red)
                        }
                    }
                }
            }
            .navigationTitle("Game Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}
