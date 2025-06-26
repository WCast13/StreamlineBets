//
//  NewGameView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/20/25.
//


// MARK: - NewGameView.swift
import SwiftUI
import SwiftData

struct NewGameView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allPlayers: [Player]
    
    @State private var gameName = ""
    @State private var gameType: GameType = .skins
    @State private var courseName = ""
    @State private var courseRating = 72.0
    @State private var slopeRating = 113.0
    @State private var par = 72
    @State private var selectedPlayers: Set<Player> = []
    @State private var showingPlayerPicker = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Game Details") {
                    TextField("Game Name", text: $gameName)
                    
                    Picker("Game Type", selection: $gameType) {
                        ForEach(GameType.allCases, id: \.self) { type in
                            Text(type.description).tag(type)
                        }
                    }
                }
                
                Section("Course Information") {
                    TextField("Course Name", text: $courseName)
                    
                    LabeledContent("Course Rating") {
                        TextField("Rating", value: $courseRating, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    LabeledContent("Slope Rating") {
                        TextField("Slope", value: $slopeRating, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    Stepper("Par: \(par)", value: $par, in: 60...80)
                }
                
                Section {
                    if selectedPlayers.isEmpty {
                        Button("Select Players") {
                            showingPlayerPicker = true
                        }
                    } else {
                        ForEach(Array(selectedPlayers).sorted { $0.name < $1.name }) { player in
                            HStack {
                                Text(player.name)
                                Spacer()
                                Button(action: { selectedPlayers.remove(player) }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        Button("Add More Players") {
                            showingPlayerPicker = true
                        }
                        .font(.caption)
                    }
                } header: {
                    Text("Players (\(selectedPlayers.count) selected)")
                }
            }
            .navigationTitle("New Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { createGame() }
                        .disabled(gameName.isEmpty || courseName.isEmpty || selectedPlayers.count < 2)
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
    
    private func createGame() {
        let game = Game(
            name: gameName,
            gameType: gameType,
            courseName: courseName,
            courseRating: courseRating,
            slopeRating: slopeRating,
            par: par
        )
        game.players = Array(selectedPlayers)
        
        modelContext.insert(game)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save game: \(error)")
        }
    }
}
