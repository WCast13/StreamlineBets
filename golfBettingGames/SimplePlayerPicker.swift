//
//  SimplePlayerPicker.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/20/25.
//

import SwiftUI
import SwiftData

struct SimplePlayerPicker: View {
    let players: [Player]
    @Binding var selectedPlayers: Set<Player>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(players) { player in
                HStack {
                    Text(player.name)
                    Spacer()
                    if selectedPlayers.contains(player) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if selectedPlayers.contains(player) {
                        selectedPlayers.remove(player)
                    } else {
                        selectedPlayers.insert(player)
                    }
                }
            }
            .navigationTitle("Select Players")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
