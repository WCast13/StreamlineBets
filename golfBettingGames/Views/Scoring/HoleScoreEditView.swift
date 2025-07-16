//
//  HoleScoreEditView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/27/25.
//


// MARK: - HoleScoreEditView
import SwiftUI
import SwiftData

struct HoleScoreEditView: View {
    @Environment(\.dismiss) private var dismiss
    let playerScore: PlayerScore
    let holeNumber: Int
    let hole: Hole?
    let courseHandicap: Int
    
    @State private var grossScore: Int
    
    private var strokesOnHole: Int {
        guard let hole = hole else { return 0 }
        return courseHandicap >= hole.handicap ? 1 : 0
    }
    
    init(playerScore: PlayerScore, holeNumber: Int, hole: Hole?, courseHandicap: Int) {
        self.playerScore = playerScore
        self.holeNumber = holeNumber
        self.hole = hole
        self.courseHandicap = courseHandicap
        
        if let existingScore = playerScore.holeScores.first(where: { $0.holeNumber == holeNumber }) {
            _grossScore = State(initialValue: existingScore.grossScore)
        } else {
            _grossScore = State(initialValue: hole?.par ?? 4)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Hole \(holeNumber)")
                            .font(.headline)
                        
                        Spacer()
                        
                        if let hole = hole {
                            VStack(alignment: .trailing) {
                                Text("Par \(hole.par)")
                                Text("Hdcp \(hole.handicap)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    if strokesOnHole > 0 {
                        Label("Gets \(strokesOnHole) stroke(s)", systemImage: "info.circle")
                            .foregroundColor(.blue)
                    }
                } header: {
                    Text("Hole Information")
                }
                
                Section {
                    Stepper("Gross Score: \(grossScore)",
                           value: $grossScore,
                           in: 1...12)
                    
                    if strokesOnHole > 0 {
                        HStack {
                            Text("Net Score")
                            Spacer()
                            Text("\(grossScore - strokesOnHole)")
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }
                    }
                } header: {
                    Text("Score")
                }
            }
            .navigationTitle("Edit Score")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveScore()
                    }
                }
            }
        }
    }
    
    private func saveScore() {
        if let existingScore = playerScore.holeScores.first(where: { $0.holeNumber == holeNumber }) {
            existingScore.grossScore = grossScore
        } else {
            let holeScore = HoleScore(
                holeNumber: holeNumber,
                grossScore: grossScore
            )
            holeScore.playerScore = playerScore
            holeScore.hole = hole
            playerScore.holeScores.append(holeScore)
        }
        
        playerScore.updateTotalScores()
        dismiss()
    }
}
