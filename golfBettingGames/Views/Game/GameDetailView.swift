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
    
    var body: some View {
        List {
            // Game Summary Section
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
            
            // Player Standings Section
            Section {
                ForEach(game.players.sorted { $0.name < $1.name }) { player in
                    HStack {
                        Text(player.name)
                        Spacer()
                        Text(formatCurrency(game.totalForPlayer(player)))
                            .foregroundColor(game.totalForPlayer(player) >= 0 ? .green : .red)
                            .fontWeight(.medium)
                    }
                }
            } header: {
                Text("Standings")
            }
            
            // Rounds Section
            Section {
                ForEach(game.rounds.sorted { $0.date > $1.date }) { round in
                    Button(action: { selectedRound = round }) {
                        RoundSummaryRow(round: round)
                    }
                    .buttonStyle(.plain)
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
        NavigationLink("Start Scoring") {
            LiveScoringView(game: game)
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}
