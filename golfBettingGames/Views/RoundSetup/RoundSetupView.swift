//
//  RoundSetupView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/19/25.
//

import SwiftUI
import SwiftData

struct RoundSetupView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let game: Game
    
    @State private var viewModel = RoundSetupViewModel()
    @State private var showingPlayerPicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                RoundDetailsSection(
                    roundType: $viewModel.roundType,
                    roundNumber: $viewModel.roundNumber,
                    holeNumber: $viewModel.holeNumber,
                    game: game
                )
                
                BettingSection(
                    betAmount: $viewModel.betAmount
                )
                
                PlayersSection(
                    selectedPlayers: $viewModel.selectedPlayers,
                    game: game,
                    showingPlayerPicker: $showingPlayerPicker
                )
                
                GameInfoSection(game: game)
            }
            .navigationTitle("New Round")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { createRound() }
                        .fontWeight(.semibold)
                        .disabled(!viewModel.canCreateRound)
                }
            }
            .sheet(isPresented: $showingPlayerPicker) {
                PlayerPickerView(
                    game: game,
                    selectedPlayers: $viewModel.selectedPlayers
                )
            }
            .alert("Round Setup", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func createRound() {
        let round = viewModel.createRound(for: game)
        
        // Create initial scores for each selected player
        viewModel.selectedPlayers.forEach { player in
            let score = PlayerScore(
                player: player,
                score: 0,
                netScore: 0,
                winnings: 0
            )
            score.round = round
            round.scores.append(score)
            modelContext.insert(score)
        }
        
        game.rounds.append(round)
        modelContext.insert(round)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            alertMessage = "Failed to create round: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}
