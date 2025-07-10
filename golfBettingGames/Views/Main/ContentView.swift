//
//  ContentView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/19/25.
//

// MARK: - ContentView.swift
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var games: [Game]
    @Query private var players: [Player]
    
    @State private var showingNewGame = false
    @State private var showingPlayerManagement = false
    @State private var selectedGame: Game?
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedGame) {
                if !activeGames.isEmpty {
                    Section("Active Games") {
                        ForEach(activeGames) { game in
                            NavigationLink(value: game) {
                                GameRowView(game: game)
                            }
                        }
                    }
                }
                
                // CHANGED: Show completed games separately
                if !completedGames.isEmpty {
                    Section("Completed Games") {
                        ForEach(completedGames) { game in
                            NavigationLink(value: game) {
                                GameRowView(game: game)
                            }
                        }
                    }
                }
                
                // ADDED: Empty state when no games
                if games.isEmpty {
                    ContentUnavailableView(
                        "No Games Yet",
                        systemImage: "figure.golf",
                        description: Text("Create your first game to get started")
                    )
                }
            }
            .navigationTitle("Golf Betting")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("New Game", systemImage: "plus") {
                        showingNewGame = true
                    }
                }
                
                ToolbarItem {
                    Button("Players", systemImage: "person.2") {
                        showingPlayerManagement = true
                    }
                }
            }
        } detail: {
            if let game = selectedGame {
                GameDetailView(game: game)
            } else {
                EmptyStateView()
            }
        }
        .sheet(isPresented: $showingNewGame) {
            NewGameView()
        }
        .sheet(isPresented: $showingPlayerManagement) {
            PlayerManagementView()
        }
    }
    
    private var activeGames: [Game] {
        games.filter { !$0.isCompleted }
            .sorted { $0.date > $1.date }
    }
    
    private var completedGames: [Game] {
        games.filter { $0.isCompleted }
            .sorted { $0.date > $1.date }
    }
}
