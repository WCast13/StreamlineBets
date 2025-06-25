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





