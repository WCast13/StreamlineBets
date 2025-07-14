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
    @Query(sort: \Player.name) private var players: [Player]
    
    @State private var showingNewPlayer = false
    @State private var selectedPlayer: Player?
    @State private var showingEditPlayer: Player?
    
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
                        NavigationLink(value: player) {
                            PlayerRowView(
                                player: player,
                                showHandicap: true,
                                showCourseHandicap: false,
                                showWinnings: false,
                                showRemoveButton: false,
                                showChevron: true
                            )
                        }
                        .swipeActions(edge: .trailing) {
                            Button("Edit") {
                                showingEditPlayer = player
                            }
                            .tint(.blue)
                        }
                    }
                    .onDelete(perform: deletePlayers)
                }
            }
            .navigationTitle("Players")
            .navigationDestination(for: Player.self) { player in
                PlayerStatsView(player: player)
            }
            .toolbar {
                // REMOVED: Done button since we're now in a tab
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add", systemImage: "plus") {
                        showingNewPlayer = true
                    }
                }
            }
            .sheet(isPresented: $showingNewPlayer) {
                AddPlayerView()
            }
            .sheet(item: $showingEditPlayer) { player in
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
