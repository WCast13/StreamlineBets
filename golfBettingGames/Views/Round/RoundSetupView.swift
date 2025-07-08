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
    
    @State private var roundType: RoundType = .full18
    @State private var roundNumber: Int = 1
    @State private var holeNumber: Int = 1
    @State private var betAmount: Double = 10.0
    @State private var selectedPlayers: Set<Player> = []
    @State private var showingPlayerPicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var createdRound: Round?
    @State private var showingLiveScoring = false
    
    private var canCreateRound: Bool {
        selectedPlayers.count >= 2 && betAmount > 0
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Round Details Section
                Section("Round Details") {
                    Picker("Round Type", selection: $roundType) {
                        ForEach(RoundType.allCases, id: \.self) { type in
                            Text(type.description).tag(type)
                        }
                    }
                    .onChange(of: roundType) { _, newValue in
                        updateRoundNumber(for: newValue)
                    }
                    
                    if roundType == .hole {
                        Stepper("Hole Number: \(holeNumber)",
                               value: $holeNumber,
                               in: 1...18)
                    }
                    
                    HStack {
                        Text("Round #")
                        Spacer()
                        Text("\(roundNumber)")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Betting Section
                Section("Betting") {
                    HStack {
                        Text("Bet Amount")
                        Spacer()
                        TextField("Amount",
                                 value: $betAmount,
                                 format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 120)
                    }
                    
                    // Quick bet buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach([5, 10, 20, 50, 100], id: \.self) { amount in
                                Button(action: { betAmount = Double(amount) }) {
                                    Text("$\(amount)")
                                        .font(.subheadline)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(betAmount == Double(amount) ? Color.accentColor : Color.secondary.opacity(0.2))
                                        .foregroundColor(betAmount == Double(amount) ? .white : .primary)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .listRowInsets(EdgeInsets())
                }
                
                // Players Section
                Section {
                    if selectedPlayers.isEmpty {
                        Button(action: { showingPlayerPicker = true }) {
                            Label("Select Players", systemImage: "person.2.circle")
                                .foregroundColor(.accentColor)
                        }
                    } else {
                        ForEach(Array(selectedPlayers).sorted { $0.name < $1.name }) { player in
                            PlayerRowForRound(player: player, game: game) {
                                selectedPlayers.remove(player)
                            }
                        }
                        
                        Button(action: { showingPlayerPicker = true }) {
                            Label("Add More Players", systemImage: "person.badge.plus")
                                .font(.subheadline)
                                .foregroundColor(.accentColor)
                        }
                    }
                } header: {
                    Text("Players (\(selectedPlayers.count) selected)")
                } footer: {
                    if selectedPlayers.count < 2 {
                        Text("Select at least 2 players to create a round")
                            .foregroundColor(.orange)
                    }
                }
                
                // Game Info Section
                Section("Game Information") {
                    HStack {
                        Text("Game Type")
                        Spacer()
                        Text(game.gameType.description)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Course")
                        Spacer()
                        Text(game.courseName)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    HStack {
                        Text("Course Rating/Slope")
                        Spacer()
                        Text("\(game.courseRating, specifier: "%.1f") / \(Int(game.slopeRating))")
                            .foregroundColor(.secondary)
                    }
                }
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
                        .disabled(!canCreateRound)
                }
            }
            .sheet(isPresented: $showingPlayerPicker) {
                PlayerPickerView(
                    game: game,
                    selectedPlayers: $selectedPlayers
                )
            }
            .alert("Round Setup", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
        .onAppear {
            // Pre-select all game players
            selectedPlayers = Set(game.players)
            updateRoundNumber(for: roundType)
        }
    }
    
    private func updateRoundNumber(for roundType: RoundType) {
        if roundType == .hole {
            let holeRounds = game.rounds.filter { $0.roundType == .hole }
            roundNumber = holeRounds.count + 1
        } else {
            roundNumber = game.rounds.count + 1
        }
    }
    
    private func createRound() {
        let round = Round(
            roundNumber: roundNumber,
            holeNumber: roundType == .hole ? holeNumber : nil,
            betAmount: betAmount,
            roundType: roundType
        )
        round.game = game
        
        // Create initial scores for each selected player
        selectedPlayers.forEach { player in
            let score = PlayerScore(player: player)
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
