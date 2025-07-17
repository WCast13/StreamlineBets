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
    
    // ADDED: Tab selection state
    @State private var selectedTab = 0
    @State private var showingNewGame = false
    @State private var selectedGame: Game?
    
    var body: some View {
        // CHANGED: Wrapped entire view in TabView
        TabView(selection: $selectedTab) {
            // MARK: - Games Tab
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
                    
                    if !completedGames.isEmpty {
                        Section("Completed Games") {
                            ForEach(completedGames) { game in
                                NavigationLink(value: game) {
                                    GameRowView(game: game)
                                }
                            }
                        }
                    }
                    
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
                }
            } detail: {
                if let game = selectedGame {
                    GameDetailView(game: game)
                } else {
                    EmptyStateView()
                }
            }
            .tabItem {
                Label("Games", systemImage: "flag.fill")
            }
            .tag(0)
            
            // MARK: - Players Tab
            NavigationStack {
                PlayerListView()
            }
            .tabItem {
                Label("Players", systemImage: "person.2.fill")
            }
            .tag(1)
            
            // MARK: - Courses Tab
            NavigationStack {
                CourseManagementView()
            }
            .tabItem {
                Label("Courses", systemImage: "mappin.and.ellipse")
            }
            .tag(2)
            
            NavigationStack {
                TeamListView()
            }
            .tabItem {
                Label("Teams", systemImage: "person.3.fill")
            }
            .tag(3)
        }
        .sheet(isPresented: $showingNewGame) {
            NewGameView()
        }
        .sheet(isPresented: $showingNewGame) {
            NewGameView()
        }
        // ADDED: Observers for tab selection from other views
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("SelectPlayersTab"))) { _ in
            selectedTab = 1
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("SelectCoursesTab"))) { _ in
            selectedTab = 2
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

