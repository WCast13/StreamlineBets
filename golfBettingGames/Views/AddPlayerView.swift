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
            Form {
                Section("Player Information") {
                    TextField("Player Name", text: $playerName)
                        .textContentType(.name)
                    
                    HStack {
                        Text("Handicap Index")
                        Spacer()
                        TextField("0.0", value: $handicapIndex, format: .number.precision(.fractionLength(1)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
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
