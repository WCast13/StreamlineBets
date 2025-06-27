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
                        Picker("Handicap Index", selection: $handicapIndex) {
                            ForEach(Array(stride(from: 0.0, through: 36.0, by: 0.1)), id: \.self) { value in
                                Text(String(format: "%.1f", value)).tag(value)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100, height: 100)
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
