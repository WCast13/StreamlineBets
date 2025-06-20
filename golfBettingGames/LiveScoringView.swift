//
//  LiveScoringView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/20/25.
//


// MARK: - LiveScoringView.swift
import SwiftUI
import SwiftData

struct LiveScoringView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let game: Game
    @State private var selectedRound: Round?
    @State private var showingNewRound = false
    @State private var showingGameSummary = false
    @State private var showingEndGameAlert = false
    
    private var activeRounds: [Round] {
        game.rounds.filter { !$0.isCompleted }
            .sorted { $0.date > $1.date }
    }
    
    private var completedRounds: [Round] {
        game.rounds.filter { $0.isCompleted }
            .sorted { $0.date > $1.date }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Game Header
                GameHeaderView(game: game)
                
                // Current Standings
                CurrentStandingsView(game: game)
                    .padding()
                
                Divider()
                
                // Active Rounds
                if activeRounds.isEmpty {
                    EmptyRoundsView(showingNewRound: $showingNewRound)
                } else {
                    ActiveRoundsList(
                        rounds: activeRounds,
                        selectedRound: $selectedRound
                    )
                }
                
                Spacer()
                
                // Action Buttons
                LiveScoringActions(
                    showingNewRound: $showingNewRound,
                    showingGameSummary: $showingGameSummary,
                    showingEndGameAlert: $showingEndGameAlert
                )
                .padding()
            }
            .navigationTitle("Live Scoring")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Summary") { showingGameSummary = true }
                }
            }
            .sheet(isPresented: $showingNewRound) {
                RoundSetupView(game: game)
            }
            .sheet(item: $selectedRound) { round in
                QuickScoreEntry(round: round)
            }
            .sheet(isPresented: $showingGameSummary) {
                GameSummaryView(game: game)
            }
            .alert("End Game", isPresented: $showingEndGameAlert) {
                Button("End Game", role: .destructive) {
                    endGame()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to end this game? All active rounds will be marked as completed.")
            }
        }
    }
    
    private func endGame() {
        game.isCompleted = true
        for round in activeRounds {
            round.isCompleted = true
        }
        try? modelContext.save()
        dismiss()
    }
}