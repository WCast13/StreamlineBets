//
//  AddPlayerView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/20/25.
//

import SwiftUI
import SwiftData

// MARK: - AddPlayerView.swift
struct AddPlayerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var playerName = ""
    @State private var handicapIndex = 9.0
    
    var body: some View {
        NavigationStack {
           VStack {
            
                Form {
                    Section {
                        VStack {
                            TextField("Player Name", text: $playerName)
                                .textContentType(.name)
                            
                            Stepper("Handicap Index (+/- 1.0 increments)",
                                   value: $handicapIndex,
                                   in: 0...54,
                                    step: 1.0)
                            Stepper("Handicap Index (+/- 0.1 increments)",
                                   value: $handicapIndex,
                                   in: 0...54,
                                    step: 0.1)
                        }
                        .font(.title2)
                        Text("Handicap Index: \(handicapIndex, specifier: "%.1f")")
                            .font(.title)
                    }
                }
               
            }
            .navigationTitle("New Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePlayer()
                    }
                    .disabled(playerName.isEmpty)
                }
            }
        }
    }
    
    private func savePlayer() {
        let player = Player(name: playerName.trimmingCharacters(in: .whitespaces),
                           handicapIndex: handicapIndex)
        modelContext.insert(player)
        try? modelContext.save()
        dismiss()
    }
}
