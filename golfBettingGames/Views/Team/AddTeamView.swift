//
//  AddTeamView.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/16/25.
//


import SwiftUI
import SwiftData

struct AddTeamView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Player.name) private var allPlayers: [Player]
    
    @State private var teamName = ""
    @State private var selectedPlayers: Set<Player> = []
    @State private var selectedColorIndex = 0
    @State private var showingPlayerPicker = false
    
    private var canCreateTeam: Bool {
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
                    if selectedPlayers.isEmpty {
                        Button(action: { showingPlayerPicker = true }) {
                            Label("Select Players", systemImage: "person.2.circle")
                                .foregroundColor(.accentColor)
                        }
                    } else {
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
                            Label("Add More Players", systemImage: "person.badge.plus")
                                .font(.subheadline)
                                .foregroundColor(.accentColor)
                        }
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
                
                // Name suggestions
                if teamName.isEmpty && !selectedPlayers.isEmpty {
                    Section("Suggested Names") {
                        let suggestions = generateTeamNameSuggestions()
                        ForEach(suggestions, id: \.self) { suggestion in
                            Button(action: { teamName = suggestion }) {
                                HStack {
                                    Text(suggestion)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text("Use")
                                        .font(.caption)
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { createTeam() }
                        .fontWeight(.semibold)
                        .disabled(!canCreateTeam)
                }
            }
            .sheet(isPresented: $showingPlayerPicker) {
                SimplePlayerPicker(
                    players: allPlayers,
                    selectedPlayers: $selectedPlayers
                )
            }
        }
    }
    
    private func generateTeamNameSuggestions() -> [String] {
        let players = Array(selectedPlayers)
        var suggestions: [String] = []
        
        if players.count == 2 {
            let firstNames = players.compactMap { $0.name.split(separator: " ").first }.map { String($0) }
            suggestions.append("\(firstNames[0]) & \(firstNames[1])")
            
            // Last initials
            let initials = players.map { player in
                let parts = player.name.split(separator: " ")
                let firstName = parts.first.map { String($0.prefix(1)) } ?? ""
                let lastName = parts.last.map { String($0.prefix(1)) } ?? ""
                return firstName + lastName
            }
            suggestions.append("Team \(initials.joined())")
        }
        
        // Generic suggestions
        suggestions.append("Team \(players.first?.name.split(separator: " ").first ?? "Golf")")
        suggestions.append("The \(["Eagles", "Birdies", "Aces", "Champions", "Legends"].randomElement()!)")
        
        return suggestions
    }
    
    private func createTeam() {
        let team = Team(
            name: teamName.trimmingCharacters(in: .whitespaces),
            color: Team.teamColors[selectedColorIndex],
            players: Array(selectedPlayers)
        )
        
        modelContext.insert(team)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save team: \(error)")
        }
    }
}

#Preview {
    AddTeamView()
        .modelContainer(for: [Team.self, Player.self], inMemory: true)
}

//
//  EditTeamView.swift
//  golfBettingGames
//
//  Created by Assistant on [Date]
//
