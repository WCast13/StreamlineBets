//
//  PlayersSection.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/19/25.
//

// MARK: - PlayersSection.swift
import SwiftUI

struct PlayersSection: View {
    @Binding var selectedPlayers: Set<Player>
    let game: Game
    @Binding var showingPlayerPicker: Bool
    
    private var sortedSelectedPlayers: [Player] {
        Array(selectedPlayers).sorted { $0.name < $1.name }
    }
    
    var body: some View {
        Section {
            if selectedPlayers.isEmpty {
                Button(action: { showingPlayerPicker = true }) {
                    Label("Select Players", systemImage: "person.2.circle")
                        .foregroundColor(.accentColor)
                }
            } else {
                ForEach(sortedSelectedPlayers) { player in
                    PlayerRowView(player: player, game: game) {
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
    }
}

