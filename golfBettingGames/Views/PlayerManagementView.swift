//
//  PlayerManagementView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/20/25.
//

// MARK: - PlayerManagementView.swift
import SwiftUI
import SwiftData

struct PlayerManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Player.name) private var players: [Player]
    
    @State private var showingNewPlayer = false
    @State private var selectedPlayer: Player?
    
    var body: some View {
        NavigationStack {
            List {
                if players.isEmpty {
                    ContentUnavailableView(
                        "No Players",
                        systemImage: "person.3",
                        description: Text("Add players to get started")
                    )
                } else {
                    ForEach(players) { player in
                        PlayerRow(player: player)
                            .onTapGesture {
                                selectedPlayer = player
                            }
                    }
                    .onDelete(perform: deletePlayers)
                }
            }
            .navigationTitle("Players")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add", systemImage: "plus") {
                        showingNewPlayer = true
                    }
                }
            }
            .sheet(isPresented: $showingNewPlayer) {
                AddPlayerView()
            }
            .sheet(item: $selectedPlayer) { player in
                EditPlayerView(player: player)
            }
        }
    }
    
    private func deletePlayers(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(players[index])
        }
        try? modelContext.save()
    }
}
