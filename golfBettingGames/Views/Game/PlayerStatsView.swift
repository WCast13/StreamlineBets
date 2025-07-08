//
//  PlayerStatsView.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/8/25.
//


// PlayerStatsView.swift
import SwiftUI
import SwiftData
import Charts

struct PlayerStatsView: View {
    @Bindable var player: Player
    @Query private var allGames: [Game]
    
    private var playerGames: [Game] {
        allGames.filter { $0.players.contains(player) }
    }
    
    private var totalRounds: Int {
        playerGames.flatMap { $0.rounds }.count
    }
    
    private var totalWinnings: Double {
        playerGames.flatMap { $0.rounds }
            .flatMap { $0.scores }
            .filter { $0.player == player }
            .reduce(0) { $0 + $1.winnings }
    }
    
    private var averageScore: Double {
        let scores = playerGames.flatMap { $0.rounds }
            .flatMap { $0.scores }
            .filter { $0.player == player && $0.score > 0 }
            .map { $0.score }
        
        guard !scores.isEmpty else { return 0 }
        return Double(scores.reduce(0, +)) / Double(scores.count)
    }
    
    private var winPercentage: Double {
        let roundsWithWinnings = playerGames.flatMap { $0.rounds }
            .flatMap { $0.scores }
            .filter { $0.player == player && $0.winnings > 0 }
            .count
        
        guard totalRounds > 0 else { return 0 }
        return Double(roundsWithWinnings) / Double(totalRounds) * 100
    }
    
    private var recentPerformance: [(date: Date, winnings: Double)] {
        playerGames.flatMap { game in
            game.rounds.compactMap { round in
                if let score = round.scores.first(where: { $0.player == player }) {
                    return (round.date, score.winnings)
                }
                return nil
            }
        }
        .sorted { $0.date < $1.date }
        .suffix(10)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Card
                VStack(spacing: 16) {
                    HStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(player.name.prefix(2).uppercased())
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.accentColor)
                            )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(player.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            HStack {
                                Label("Handicap: \(player.handicapIndex, specifier: "%.1f")",
                                      systemImage: "figure.golf")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
                
                // Stats Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    StatCard(
                        title: "Total Winnings",
                        value: formatCurrency(totalWinnings),
                        icon: "dollarsign.circle.fill",
                        color: totalWinnings >= 0 ? .green : .red
                    )
                    
                    StatCard(
                        title: "Games Played",
                        value: "\(playerGames.count)",
                        icon: "flag.fill",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Win Rate",
                        value: "\(Int(winPercentage))%",
                        icon: "trophy.fill",
                        color: .orange
                    )
                    
                    StatCard(
                        title: "Avg Score",
                        value: averageScore > 0 ? "\(Int(averageScore))" : "—",
                        icon: "chart.bar.fill",
                        color: .purple
                    )
                }
                
                // Performance Chart
                if !recentPerformance.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Performance")
                            .font(.headline)
                        
                        Chart(recentPerformance, id: \.date) { item in
                            BarMark(
                                x: .value("Date", item.date, unit: .day),
                                y: .value("Winnings", item.winnings)
                            )
                            .foregroundStyle(item.winnings >= 0 ? Color.green : Color.red)
                        }
                        .frame(height: 200)
                        .padding(.vertical)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                }
                
                // Recent Games
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Games")
                        .font(.headline)
                    
                    ForEach(playerGames.prefix(5)) { game in
                        GameHistoryRow(game: game, player: player)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
            }
            .padding()
        }
        .navigationTitle("Player Stats")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}
