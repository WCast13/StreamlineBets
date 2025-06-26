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
                    
                    HStack {
                        Text("Handicap Index")
                        Spacer()
                        TextField("0.0", value: $handicapIndex, format: .number.precision(.fractionLength(1)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
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
