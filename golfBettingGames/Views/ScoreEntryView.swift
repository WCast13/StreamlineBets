//
//  ScoreEntryView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/25/25.
//

import SwiftUI
import SwiftData

// MARK: - ScoreEntryView.swift
struct ScoreEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var score: PlayerScore
    let round: Round
    let onSave: () -> Void
    
    @State private var grossScore: Int
    @State private var notes: String
    
    private var courseHandicap: Int {
        guard let player = score.player,
              let game = round.game else { return 0 }
        
        return player.courseHandicap(
            courseRating: game.courseRating,
            slopeRating: game.slopeRating,
            par: game.par
        )
    }
    
    private var strokesForHole: Int {
        if round.roundType == .hole, let holeNumber = round.holeNumber {
            // Standard stroke allocation
            return courseHandicap >= holeNumber ? 1 : 0
        }
        return 0
    }
    
    init(score: PlayerScore, round: Round, onSave: @escaping () -> Void) {
        self.score = score
        self.round = round
        self.onSave = onSave
        self._grossScore = State(initialValue: score.score > 0 ? score.score : 4)
        self._notes = State(initialValue: score.notes)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(score.player?.name ?? "Unknown")
                        .font(.headline)
                    
                    if let holeNumber = round.holeNumber {
                        LabeledContent("Hole", value: "\(holeNumber)")
                    }
                    
                    LabeledContent("Course Handicap", value: "\(courseHandicap)")
                    
                    if strokesForHole > 0 {
                        LabeledContent("Strokes on this hole", value: "\(strokesForHole)")
                            .foregroundColor(.blue)
                    }
                } header: {
                    Text("Player Information")
                }
                
                Section {
                    Stepper("Gross Score: \(grossScore)",
                           value: $grossScore,
                           in: 1...15)
                    
                    LabeledContent("Net Score") {
                        Text("\(grossScore - strokesForHole)")
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                } header: {
                    Text("Score Entry")
                }
                
                Section {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Notes")
                }
            }
            .navigationTitle("Enter Score")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveScore()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func saveScore() {
        score.score = grossScore
        score.netScore = grossScore - strokesForHole
        score.notes = notes
        onSave()
        dismiss()
    }
}
