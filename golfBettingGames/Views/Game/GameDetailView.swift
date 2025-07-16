//
//  GameDetailView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/20/25.
//

// MARK: - GameDetailView.swift
import SwiftUI
import SwiftData

struct GameDetailView: View {
    @Bindable var game: Game
    @State private var showingNewRound = false
    @State private var selectedRound: Round?
    @State private var selectedPlayer: Player?
    
    private var incompleteRounds: [Round] {
        game.rounds.filter { !$0.isCompleted }
            .sorted { $0.date > $1.date }
    }
    
    var body: some View {
        List {
            // Game Information Section
            Section {
                LabeledContent("Course", value: game.courseName)
                LabeledContent("Game Type", value: game.gameType.description)
                LabeledContent("Date", value: game.date.formatted(date: .abbreviated, time: .shortened))
                
                if !game.notes.isEmpty {
                    LabeledContent("Notes") {
                        Text(game.notes)
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text("Game Information")
            }
            
            // Rounds Section
            Section {
                ForEach(game.rounds.sorted { $0.date > $1.date }) { round in
                    // For incomplete rounds - direct navigation
                    if !round.isCompleted {
                        NavigationLink(destination: LiveScoringView(round: round)) {
                            RoundSummaryRow(round: round)
                        }
                        .buttonStyle(.plain)
                    } else {
                        // For completed rounds - sheet presentation
                        Button(action: { selectedRound = round }) {
                            RoundSummaryRow(round: round)
                        }
                        .buttonStyle(.plain)
                    }
                }
            } header: {
                HStack {
                    Text("Rounds")
                    Spacer()
                    Button("Add Round", systemImage: "plus.circle.fill") {
                        showingNewRound = true
                    }
                    .font(.caption)
                }
            }
            
            // Players Section
            Section {
                ForEach(game.players.sorted { $0.name < $1.name }) { player in
                    Button(action: { selectedPlayer = player }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(player.name)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Text("Handicap: \(player.handicapIndex, specifier: "%.1f")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            let totalWinnings = game.totalForPlayer(player)
                            Text(formatCurrency(totalWinnings))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(totalWinnings >= 0 ? .green : .red)
                        }
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text("Players (\(game.players.count))")
            }
        }
        .navigationTitle(game.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(game.isCompleted ? "Reopen" : "Complete") {
                    game.isCompleted.toggle()
                }
            }
        }
        .sheet(isPresented: $showingNewRound) {
            RoundSetupView(game: game)
        }
        .sheet(item: $selectedRound) { round in
            RoundDetailView(round: round)
        }
        .sheet(item: $selectedPlayer) { player in
            NavigationStack {
                PlayerStatsView(player: player)
            }
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

