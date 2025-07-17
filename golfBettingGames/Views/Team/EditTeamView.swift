//
//  EditTeamView.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/16/25.
//

import SwiftUI
import SwiftData

struct EditTeamView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Player.name) private var allPlayers: [Player]
    @Bindable var team: Team
    
    @State private var teamName: String = ""
    @State private var selectedPlayers: Set<Player> = []
    @State private var selectedColorIndex: Int = 0
    @State private var showingPlayerPicker = false
    @State private var showingDeleteAlert = false
    
    private var canSaveTeam: Bool {
        !teamName.isEmpty && !selectedPlayers.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Team Information") {
                    TextField("Team Name", text: $teamName)
                    
                    // Color picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Team Color")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                            ForEach(Array(Team.teamColors.enumerated()), id: \.offset) { index, colorHex in
                                Circle()
                                    .fill(Color(hex: colorHex) ?? .blue)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: selectedColorIndex == index ? 3 : 0)
                                    )
                                    .onTapGesture {
                                        selectedColorIndex = index
                                    }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    ForEach(Array(selectedPlayers).sorted { $0.name < $1.name }) { player in
                        HStack {
                            PlayerRowView(
                                player: player,
                                showHandicap: true,
                                showCourseHandicap: false,
                                showWinnings: false,
                                showRemoveButton: true,
                                showChevron: false,
                                onRemove: {
                                    selectedPlayers.remove(player)
                                }
                            )
                        }
                    }
                    
                    Button(action: { showingPlayerPicker = true }) {
                        Label("Add Players", systemImage: "person.badge.plus")
                            .font(.subheadline)
                            .foregroundColor(.accentColor)
                    }
                } header: {
                    Text("Team Members (\(selectedPlayers.count))")
                } footer: {
                    if !selectedPlayers.isEmpty {
                        let avgHandicap = selectedPlayers.reduce(0.0) { $0 + $1.handicapIndex } / Double(selectedPlayers.count)
                        Text("Average Handicap: \(avgHandicap, specifier: "%.1f")")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Team Statistics
                if team.gamesPlayed > 0 {
                    Section("Statistics") {
                        LabeledContent("Games Played", value: "\(team.gamesPlayed)")
                        LabeledContent("Games Won", value: "\(team.gamesWon)")
                        LabeledContent("Win Rate", value: "\(Int(team.winPercentage))%")
                        LabeledContent("Total Winnings") {
                            Text(formatCurrency(team.totalWinnings))
                                .fontWeight(.medium)
                                .foregroundColor(team.totalWinnings >= 0 ? .green : .red)
                        }
                    }
                }
                
                Section {
                    Toggle("Active Team", isOn: $team.isActive)
                }
                
                Section {
                    Button(action: { showingDeleteAlert = true }) {
                        Label("Delete Team", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Edit Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveChanges() }
                        .fontWeight(.semibold)
                        .disabled(!canSaveTeam)
                }
            }
            .sheet(isPresented: $showingPlayerPicker) {
                SimplePlayerPicker(
                    players: allPlayers.filter { !selectedPlayers.contains($0) },
                    selectedPlayers: $selectedPlayers
                )
            }
            .alert("Delete Team", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    deleteTeam()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this team? This action cannot be undone.")
            }
        }
        .onAppear {
            teamName = team.name
            selectedPlayers = Set(team.players)
            if let index = Team.teamColors.firstIndex(of: team.color) {
                selectedColorIndex = index
            }
        }
    }
    
    private func saveChanges() {
        team.name = teamName.trimmingCharacters(in: .whitespaces)
        team.color = Team.teamColors[selectedColorIndex]
        team.players = Array(selectedPlayers)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save team changes: \(error)")
        }
    }
    
    private func deleteTeam() {
        modelContext.delete(team)
        dismiss()
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}
