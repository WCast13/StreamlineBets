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
    @State private var handicapIndexText = "9.0"
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Player Information") {
                    TextField("Player Name", text: $playerName)
                        .textContentType(.name)
                    
                    TextField("Handicap Index", text: $handicapIndexText)
                        .keyboardType(.decimalPad)
                        .frame(width: 100)
                    
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
        let handicapValue = Double(handicapIndexText) ?? 0.0
        let player = Player(name: playerName.trimmingCharacters(in: .whitespaces),
                           handicapIndex: handicapValue)
        modelContext.insert(player)
        try? modelContext.save()
        dismiss()
    }
}
