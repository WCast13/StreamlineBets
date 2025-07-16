//
//  PlayerPickerView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/19/25.
//

// MARK: - PlayerPickerView.swift
import SwiftUI
import SwiftData

struct PlayerPickerView: View {
    @Environment(\.dismiss) private var dismiss
    
    let game: Game
    @Binding var selectedPlayers: Set<Player>
    
    private var availablePlayers: [Player] {
        game.players.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(availablePlayers) { player in
                    PlayerSelectionRow(
                        player: player,
                        isSelected: selectedPlayers.contains(player)
                    ) {
                        toggleSelection(for: player)
                    }
                }
            }
            .navigationTitle("Select Players")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func toggleSelection(for player: Player) {
        if selectedPlayers.contains(player) {
            selectedPlayers.remove(player)
        } else {
            selectedPlayers.insert(player)
        }
    }
}

