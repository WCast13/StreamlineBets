// MARK: - RoundDetailView.swift
import SwiftUI
import SwiftData

struct RoundDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var round: Round
    @State private var editingScore: PlayerScore?
    @State private var showingWinningsCalculator = false
    @State private var showingDeleteAlert = false
    
    private var sortedScores: [PlayerScore] {
        round.scores.sorted {
            ($0.player?.name ?? "") < ($1.player?.name ?? "")
        }
    }
    
    private var isAllScoresEntered: Bool {
        round.scores.allSatisfy { $0.score > 0 }
    }
    
    var body: some View {
        NavigationStack {
            List {
                RoundInfoSection(round: round)
                
                ScoresSection(
                    scores: sortedScores,
                    round: round,
                    editingScore: $editingScore
                )
                
                if isAllScoresEntered {
                    WinningsSection(round: round)
                }
                
                ActionsSection(
                    round: round,
                    showingWinningsCalculator: $showingWinningsCalculator,
                    showingDeleteAlert: $showingDeleteAlert
                )
            }
            .navigationTitle("Round \(round.roundNumber)")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        saveAndDismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .sheet(item: $editingScore) { score in
                ScoreEntryView(
                    score: score,
                    round: round,
                    onSave: { calculateWinnings() }
                )
            }
            .sheet(isPresented: $showingWinningsCalculator) {
                WinningsCalculatorView(
                    round: round,
                    onApply: { calculateWinnings() }
                )
            }
            .alert("Delete Round", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    deleteRound()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this round? This action cannot be undone.")
            }
        }
    }
    
    private func saveAndDismiss() {
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save: \(error)")
        }
    }
    
    private func calculateWinnings() {
        guard let game = round.game else { return }
        
        switch game.gameType {
        case .skins:
            calculateSkinsWinnings()
        case .nassau:
            calculateNassauWinnings()
        case .matchPlay:
            calculateMatchPlayWinnings()
        case .strokePlay:
            calculateStrokePlayWinnings()
        default:
            // Custom game types would need their own calculation
            break
        }
        
        round.isCompleted = isAllScoresEntered
    }
    
    private func calculateSkinsWinnings() {
        let scores = round.scores
        guard !scores.isEmpty else { return }
        
        // Find the lowest net score
        let lowestNetScore = scores.map { $0.netScore }.min() ?? 0
        let winners = scores.filter { $0.netScore == lowestNetScore }
        
        if winners.count == 1 {
            // Single winner takes all
            let totalPot = round.betAmount * Double(scores.count)
            for score in scores {
                if score.netScore == lowestNetScore {
                    score.winnings = totalPot - round.betAmount
                } else {
                    score.winnings = -round.betAmount
                }
            }
        } else {
            // Tie - carry over or split
            for score in scores {
                score.winnings = 0
            }
        }
    }
    
    private func calculateNassauWinnings() {
        // Nassau: Front 9, Back 9, and Total
        // This is a simplified version
        let scores = round.scores
        guard !scores.isEmpty else { return }
        
        // For now, treat it like match play
        calculateMatchPlayWinnings()
    }
    
    private func calculateMatchPlayWinnings() {
        // Simple match play calculation
        let scores = round.scores
        guard scores.count >= 2 else { return }
        
        let sortedByNet = scores.sorted { $0.netScore < $1.netScore }
        let winner = sortedByNet[0]
        let loser = sortedByNet[1]
        
        if winner.netScore < loser.netScore {
            winner.winnings = round.betAmount
            loser.winnings = -round.betAmount
        } else {
            // Tie
            winner.winnings = 0
            loser.winnings = 0
        }
        
        // Handle more than 2 players
        for i in 2..<sortedByNet.count {
            sortedByNet[i].winnings = 0
        }
    }
    
    private func calculateStrokePlayWinnings() {
        let scores = round.scores
        guard !scores.isEmpty else { return }
        
        // Sort by net score
        let sortedScores = scores.sorted { $0.netScore < $1.netScore }
        
        // Simple payout structure
        if sortedScores.count >= 3 {
            sortedScores[0].winnings = round.betAmount * 2
            sortedScores[1].winnings = round.betAmount
            sortedScores[2].winnings = -round.betAmount
            for i in 3..<sortedScores.count {
                sortedScores[i].winnings = -round.betAmount * 2
            }
        }
    }
    
    private func deleteRound() {
        modelContext.delete(round)
        dismiss()
    }
}

// MARK: - RoundInfoSection.swift
struct RoundInfoSection: View {
    let round: Round
    
    private var gameInfo: (name: String, course: String)? {
        guard let game = round.game else { return nil }
        return (game.name, game.courseName)
    }
    
    var body: some View {
        Section("Round Information") {
            if let gameInfo = gameInfo {
                LabeledContent("Game", value: gameInfo.name)
                LabeledContent("Course", value: gameInfo.course)
            }
            
            LabeledContent("Type", value: round.roundType.description)
            
            if let holeNumber = round.holeNumber {
                LabeledContent("Hole", value: "Hole \(holeNumber)")
            }
            
            LabeledContent("Bet Amount") {
                Text("$\(round.betAmount, specifier: "%.2f")")
                    .fontWeight(.medium)
            }
            
            LabeledContent("Date", value: round.date.formatted(date: .abbreviated, time: .shortened))
            
            HStack {
                Text("Status")
                Spacer()
                StatusBadge(isCompleted: round.isCompleted)
            }
        }
    }
}

// MARK: - ScoresSection.swift
struct ScoresSection: View {
    let scores: [PlayerScore]
    let round: Round
    @Binding var editingScore: PlayerScore?
    
    var body: some View {
        Section("Scores") {
            ForEach(scores) { score in
                ScoreRowView(
                    score: score,
                    round: round,
                    onTap: { editingScore = score }
                )
            }
        }
    }
}

// MARK: - ScoreRowView.swift
struct ScoreRowView: View {
    @Bindable var score: PlayerScore
    let round: Round
    let onTap: () -> Void
    
    private var courseHandicap: Int {
        guard let player = score.player,
              let game = round.game else { return 0 }
        
        return player.courseHandicap(
            courseRating: game.courseRating,
            slopeRating: game.slopeRating,
            par: game.par
        )
    }
    
    private var strokesReceived: Int {
        // For single hole, calculate strokes based on hole handicap
        if round.roundType == .hole, let holeNumber = round.holeNumber {
            // Assuming standard stroke allocation
            return courseHandicap >= holeNumber ? 1 : 0
        }
        return courseHandicap
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(score.player?.name ?? "Unknown")
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 12) {
                        if score.score > 0 {
                            Label("\(score.score)", systemImage: "flag.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("Net: \(score.netScore)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(4)
                        } else {
                            Text("Tap to enter score")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        
                        if strokesReceived > 0 {
                            Text("(\(strokesReceived) strokes)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                if score.winnings != 0 {
                    Text(formatCurrency(score.winnings))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(score.winnings > 0 ? .green : .red)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

// MARK: - WinningsSection.swift
struct WinningsSection: View {
    let round: Round
    
    private var totalPot: Double {
        round.betAmount * Double(round.scores.count)
    }
    
    private var winners: [PlayerScore] {
        round.scores.filter { $0.winnings > 0 }
            .sorted { $0.winnings > $1.winnings }
    }
    
    var body: some View {
        Section("Results") {
            LabeledContent("Total Pot") {
                Text("$\(totalPot, specifier: "%.2f")")
                    .fontWeight(.medium)
            }
            
            if !winners.isEmpty {
                ForEach(winners) { winner in
                    HStack {
                        Label(winner.player?.name ?? "Unknown",
                              systemImage: "trophy.fill")
                            .foregroundColor(.orange)
                        
                        Spacer()
                        
                        Text("+$\(winner.winnings, specifier: "%.2f")")
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                    }
                }
            }
        }
    }
}

// MARK: - ActionsSection.swift
struct ActionsSection: View {
    let round: Round
    @Binding var showingWinningsCalculator: Bool
    @Binding var showingDeleteAlert: Bool
    
    var body: some View {
        Section {
            Button(action: { showingWinningsCalculator = true }) {
                Label("Adjust Winnings", systemImage: "dollarsign.circle")
            }
            
            Button(action: { showingDeleteAlert = true }) {
                Label("Delete Round", systemImage: "trash")
                    .foregroundColor(.red)
            }
        }
    }
}

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

// MARK: - WinningsCalculatorView.swift
struct WinningsCalculatorView: View {
    @Environment(\.dismiss) private var dismiss
    let round: Round
    let onApply: () -> Void
    
    @State private var winningsDict: [UUID: Double] = [:]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Manually adjust winnings for each player")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text("Adjust Winnings")
                }
                
                Section {
                    ForEach(round.scores) { score in
                        if let player = score.player {
                            HStack {
                                Text(player.name)
                                Spacer()
                                TextField("Amount",
                                         value: Binding(
                                            get: { winningsDict[score.id] ?? score.winnings },
                                            set: { winningsDict[score.id] = $0 }
                                         ),
                                         format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                                    .keyboardType(.numbersAndPunctuation)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 120)
                            }
                        }
                    }
                } header: {
                    Text("Player Winnings")
                } footer: {
                    let total = winningsDict.values.reduce(0, +)
                    Text("Total: \(formatCurrency(total))")
                        .foregroundColor(abs(total) < 0.01 ? .green : .orange)
                }
            }
            .navigationTitle("Winnings Calculator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        applyWinnings()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            // Initialize with current winnings
            for score in round.scores {
                winningsDict[score.id] = score.winnings
            }
        }
    }
    
    private func applyWinnings() {
        for score in round.scores {
            if let winnings = winningsDict[score.id] {
                score.winnings = winnings
            }
        }
        onApply()
        dismiss()
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

// MARK: - StatusBadge.swift
struct StatusBadge: View {
    let isCompleted: Bool
    
    var body: some View {
        Text(isCompleted ? "Completed" : "In Progress")
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(isCompleted ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
            .foregroundColor(isCompleted ? .green : .orange)
            .cornerRadius(12)
    }
}
