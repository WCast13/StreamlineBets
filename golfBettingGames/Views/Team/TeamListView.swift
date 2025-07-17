//
//  TeamListView.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/16/25.
//


import SwiftUI
import SwiftData

struct TeamListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Team.name) private var teams: [Team]
    
    @State private var showingNewTeam = false
    @State private var selectedTeam: Team?
    
    var body: some View {
        List {
            if teams.isEmpty {
                ContentUnavailableView(
                    "No Teams",
                    systemImage: "person.3",
                    description: Text("Create teams for team-based games")
                )
            } else {
                ForEach(teams) { team in
                    NavigationLink(value: team) {
                        TeamRowView(team: team)
                    }
                    .swipeActions(edge: .trailing) {
                        Button("Edit") {
                            selectedTeam = team
                        }
                        .tint(.blue)
                        
                        Button("Delete", role: .destructive) {
                            deleteTeam(team)
                        }
                    }
                }
            }
        }
        .navigationTitle("Teams")
        .navigationDestination(for: Team.self) { team in
            TeamDetailView(team: team)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add", systemImage: "plus") {
                    showingNewTeam = true
                }
            }
        }
        .sheet(isPresented: $showingNewTeam) {
            AddTeamView()
        }
        .sheet(item: $selectedTeam) { team in
            EditTeamView(team: team)
        }
    }
    
    private func deleteTeam(_ team: Team) {
        modelContext.delete(team)
        try? modelContext.save()
    }
}

// MARK: - Team Row View
struct TeamRowView: View {
    let team: Team
    
    private var colorFromHex: Color {
        Color(hex: team.color) ?? .blue
    }
    
    var body: some View {
        HStack {
            // Team color indicator
            Circle()
                .fill(colorFromHex)
                .frame(width: 40, height: 40)
                .overlay(
                    Text("\(team.players.count)")
                        .font(.headline)
                        .foregroundColor(.white)
                )
            
            // Team info
            VStack(alignment: .leading, spacing: 4) {
                Text(team.name)
                    .font(.headline)
                
                if !team.players.isEmpty {
                    Text(team.players.map { $0.name }.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack {
                    if team.gamesPlayed > 0 {
                        Label("\(team.gamesPlayed) games", systemImage: "flag.fill")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    if team.totalWinnings != 0 {
                        Label(formatCurrency(team.totalWinnings), systemImage: "dollarsign.circle")
                            .font(.caption2)
                            .foregroundColor(team.totalWinnings >= 0 ? .green : .red)
                    }
                }
            }
            
            Spacer()
            
            // Average handicap
            if !team.players.isEmpty {
                VStack(alignment: .trailing) {
                    Text("Avg HCP")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(team.averageHandicap, specifier: "%.1f")")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

// MARK: - Color Extension
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    NavigationStack {
        TeamListView()
    }
    .modelContainer(for: Team.self, inMemory: true)
}
