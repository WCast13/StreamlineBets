//
//  EditPlayerView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/20/25.
//


import SwiftUI
import SwiftData


// MARK: - EditPlayerView.swift
struct EditPlayerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var player: Player
    
    @State private var name: String = ""
    @State private var handicapIndex: Double = 0.0
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Player Information") {
                    TextField("Name", text: $name)
                        .textContentType(.name)
                    
                    Stepper("Handicap: \(handicapIndex, specifier: "%.1f")",
                           value: $handicapIndex,
                           in: 0...54,
                           step: 0.1)
                }
                
                Section {
                    Toggle("Active Player", isOn: $player.isActive)
                }
            }
            .navigationTitle("Edit Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                }
            }
        }
        .onAppear {
            name = player.name
            handicapIndex = player.handicapIndex
        }
    }
    
    private func saveChanges() {
        player.name = name.trimmingCharacters(in: .whitespaces)
        player.handicapIndex = handicapIndex
        try? modelContext.save()
        dismiss()
    }
}
