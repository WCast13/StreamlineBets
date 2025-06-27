// MARK: - RoundDetailView.swift
import SwiftUI
import SwiftData

struct RoundDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var round: Round
    @State private var editingScore: PlayerScore?
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
                // Round Info Section
                Section("Round Information") {
                    if let game = round.game {
                        LabeledContent("Game", value: game.name)
                        LabeledContent("Course", value: game.courseName)
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
                
                // Scores Section
                Section("Scores") {
                    ForEach(sortedScores) { score in
                        ScoreRowView(score: score, round: round) {
                            editingScore = score
                        }
                    }
                }
                
                // Results Section
                if isAllScoresEntered {
                    Section("Results") {
                        let totalPot = round.betAmount * Double(round.scores.count)
                        LabeledContent("Total Pot") {
                            Text("$\(totalPot, specifier: "%.2f")")
                                .fontWeight(.medium)
                        }
                        
                        let winners = round.scores.filter { $0.winnings > 0 }
                            .sorted { $0.winnings > $1.winnings }
                        
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
                
                // Actions Section
                Section {
                    Button(action: { calculateWinnings() }) {
                        Label("Calculate Winnings", systemImage: "dollarsign.circle")
                    }
                    .disabled(!isAllScoresEntered)
                    
                    Button(action: { showingDeleteAlert = true }) {
                        Label("Delete Round", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }
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
                ScoreEntryView(score: score, round: round) {
                    calculateWinnings()
                }
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
        default:
            calculateSkinsWinnings() // Default to skins for now
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
    
    private func deleteRound() {
        modelContext.delete(round)
        dismiss()
    }
}
