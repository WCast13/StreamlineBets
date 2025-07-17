//
//  TeamDetailView.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/16/25.
//

import SwiftUI
import SwiftData
import Charts

struct TeamDetailView: View {
    @Bindable var team: Team
    @State private var showingEditTeam = false
    @State private var selectedTimeRange = TimeRange.all
    
    enum TimeRange: String, CaseIterable {
        case all = "All Time"
        case month = "This Month"
        case year = "This Year"
    }
    
    private var teamGames: [Game] {
        team.games.sorted { $0.date > $1.date }
    }
    
    private var filteredGames: [Game] {
        switch selectedTimeRange {
        case .all:
            return teamGames
        case .month:
            let startOfMonth = Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date()
            return teamGames.filter { $0.date >= startOfMonth }
        case .year:
            let startOfYear = Calendar.current.dateInterval(of: .year, for: Date())?.start ?? Date()
            return teamGames.filter { $0.date >= startOfYear }
        }
    }
    
    private var colorFromHex: Color {
        Color(hex: team.color) ?? .blue
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Card
                VStack(spacing: 16) {
                    HStack {
                        Circle()
                            .fill(colorFromHex)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text("\(team.players.count)")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(team.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Average Handicap: \(team.averageHandicap, specifier: "%.1f")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
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
                        value: formatCurrency(team.totalWinnings),
                        icon: "dollarsign.circle.fill",
                        color: team.totalWinnings >= 0 ? .green : .red
                    )
                    
                    StatCard(
                        title: "Games Played",
                        value: "\(team.gamesPlayed)",
                        icon: "flag.fill",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Win Rate",
                        value: "\(Int(team.winPercentage))%",
                        icon: "trophy.fill",
                        color: .orange
                    )
                    
                    StatCard(
                        title: "Members",
                        value: "\(team.players.count)",
                        icon: "person.3.fill",
                        color: colorFromHex
                    )
                }
                
                // Team Members
                VStack(alignment: .leading, spacing: 12) {
                    Text("Team Members")
                        .font(.headline)
                    
                    ForEach(team.players.sorted { $0.name < $1.name }) { player in
                        HStack {
                            Circle()
                                .fill(Color.accentColor.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text(player.name.prefix(2).uppercased())
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.accentColor)
                                )
                            
                            VStack(alignment: .leading) {
                                Text(player.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text("Handicap: \(player.handicapIndex, specifier: "%.1f")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Individual contribution
                            if let contribution = calculatePlayerContribution(player) {
                                Text(formatCurrency(contribution))
                                    .font(.subheadline)
                                    .foregroundColor(contribution >= 0 ? .green : .red)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
                
                // Recent Games
                if !filteredGames.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Game History")
                                .font(.headline)
                            
                            Spacer()
                            
                            Picker("Time Range", selection: $selectedTimeRange) {
                                ForEach(TimeRange.allCases, id: \.self) { range in
                                    Text(range.rawValue).tag(range)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        ForEach(filteredGames.prefix(10)) { game in
                            TeamGameHistoryRow(team: team, game: game)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                }
                
                // Performance Chart
                if !teamGames.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Performance Trend")
                            .font(.headline)
                        
                        TeamPerformanceChart(team: team, games: filteredGames)
                            .frame(height: 200)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                }
            }
            .padding()
        }
        .navigationTitle("Team Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showingEditTeam = true
                }
            }
        }
        .sheet(isPresented: $showingEditTeam) {
            EditTeamView(team: team)
        }
    }
    
    private func calculatePlayerContribution(_ player: Player) -> Double? {
        var total = 0.0
        var hasContribution = false
        
        for game in teamGames {
            for round in game.rounds {
                if let score = round.scores.first(where: { $0.player?.id == player.id }) {
                    total += score.winnings
                    hasContribution = true
                }
            }
        }
        
        return hasContribution ? total : nil
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

// MARK: - Team Game History Row
struct TeamGameHistoryRow: View {
    let team: Team
    let game: Game
    
    private var teamWinnings: Double {
        team.totalForGame(game)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(game.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Text(game.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(game.courseName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Text(formatCurrency(teamWinnings))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(teamWinnings >= 0 ? .green : .red)
        }
        .padding(.vertical, 8)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

// MARK: - Team Performance Chart
struct TeamPerformanceChart: View {
    let team: Team
    let games: [Game]
    
    private var chartData: [(date: Date, cumulativeWinnings: Double)] {
        var cumulative = 0.0
        var data: [(Date, Double)] = []
        
        for game in games.reversed() {
            cumulative += team.totalForGame(game)
            data.append((game.date, cumulative))
        }
        
        return data
    }
    
    var body: some View {
        if !chartData.isEmpty {
            Chart(chartData, id: \.date) { item in
                LineMark(
                    x: .value("Date", item.date),
                    y: .value("Winnings", item.cumulativeWinnings)
                )
                .foregroundStyle(Color(hex: team.color) ?? .blue)
                
                AreaMark(
                    x: .value("Date", item.date),
                    y: .value("Winnings", item.cumulativeWinnings)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            (Color(hex: team.color) ?? .blue).opacity(0.3),
                            (Color(hex: team.color) ?? .blue).opacity(0.05)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        } else {
            Text("No game data available")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - StatCard Component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview("Team Detail") {
    NavigationStack {
        TeamDetailView(team: {
            let player1 = Player(name: "Tiger Woods", handicapIndex: 0.0)
            let player2 = Player(name: "Phil Mickelson", handicapIndex: 2.5)
            
            let team = Team(
                name: "Dream Team",
                color: Team.teamColors[2],
                players: [player1, player2]
            )
            team.gamesPlayed = 10
            team.gamesWon = 7
            team.totalWinnings = 500.0
            return team
        }())
    }
    .modelContainer(for: [Team.self, Player.self, Game.self], inMemory: true)
}
