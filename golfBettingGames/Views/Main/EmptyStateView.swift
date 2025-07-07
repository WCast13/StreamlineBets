//
//  EmptyStateView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/20/25.
//

import SwiftUI
import SwiftData

struct EmptyStateView: View {
    @Query private var games: [Game]
    @State private var showingNewGame = false
    
    private var hasGames: Bool {
        !games.isEmpty
    }
    
    private var activeGames: [Game] {
        games.filter { game in
            game.rounds.contains { !$0.isCompleted }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Active Games Quick Access
                if !activeGames.isEmpty {
                    VStack(spacing: 16) {
                        Text("Active Rounds")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(activeGames) { game in
                                ForEach(game.rounds.filter { !$0.isCompleted }) { round in
                                    ActiveRoundCard(game: game, round: round)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 32)
                    
                    Divider()
                        .padding(.vertical)
                }
                
                // Main Empty State
                VStack(spacing: 24) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.1))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "figure.golf")
                            .font(.system(size: 60))
                            .foregroundColor(.accentColor)
                    }
                    
                    // Text
                    VStack(spacing: 12) {
                        Text(hasGames ? "Select a Game" : "Welcome to Golf Betting")
                            .font(.title)
                            .fontWeight(.semibold)
                        
                        Text(hasGames ?
                             "Choose a game from the sidebar to view details and scoring" :
                             "Track your golf betting games, calculate handicaps, and keep score"
                        )
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 400)
                    }
                    
                    // Quick Actions
                    if !hasGames {
                        VStack(spacing: 16) {
                            Button(action: { showingNewGame = true }) {
                                Label("Create Your First Game", systemImage: "plus.circle.fill")
                                    .font(.headline)
                                    .frame(maxWidth: 300)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            
                            HStack(spacing: 24) {
                                QuickStartItem(
                                    icon: "person.2.fill",
                                    title: "Add Players",
                                    description: "Set up player profiles"
                                )
                                
                                QuickStartItem(
                                    icon: "flag.fill",
                                    title: "Add Courses",
                                    description: "Save your favorite courses"
                                )
                                
                                QuickStartItem(
                                    icon: "chart.line.uptrend.xyaxis",
                                    title: "Track Progress",
                                    description: "View stats and winnings"
                                )
                            }
                            .frame(maxWidth: 600)
                        }
                        .padding(.top, 16)
                    }
                }
                .padding(.vertical, 48)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
        .sheet(isPresented: $showingNewGame) {
            NewGameView()
        }
    }
}

struct ActiveRoundCard: View {
    let game: Game
    let round: Round
    @State private var showingLiveScoring = false
    
    var body: some View {
        Button(action: { showingLiveScoring = true }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "flag.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    
                    Spacer()
                    
                    Text("Round \(round.roundNumber)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(game.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(game.courseName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack {
                    if round.holesPlayed > 0 {
                        Label("\(round.holesPlayed) holes", systemImage: "flag")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    } else {
                        Text("Ready to start")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "play.fill")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Circle().fill(Color.orange))
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .fullScreenCover(isPresented: $showingLiveScoring) {
            LiveScoringView(round: round)
        }
    }
}

struct QuickStartItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 50, height: 50)
                .background(Color.accentColor.opacity(0.1))
                .cornerRadius(12)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: 150)
    }
}

