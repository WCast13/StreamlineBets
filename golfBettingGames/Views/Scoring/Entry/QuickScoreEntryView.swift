//
//  QuickScoreEntryView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/27/25.
//


import SwiftUI
import SwiftData

struct QuickScoreEntryView: View {
    @Environment(\.dismiss) private var dismiss
    let round: Round
    
    @State private var currentHole = 1
    @State private var scores: [UUID: Int] = [:]
    
    private var course: Course? {
        round.game?.course
    }
    
    private var currentHoleInfo: Hole? {
        course?.holes.first(where: { $0.number == currentHole })
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Hole Navigation
                HoleNavigationView(
                    currentHole: $currentHole,
                    totalHoles: course?.holes.count ?? 18,
                    holeInfo: currentHoleInfo
                )
                
                Divider()
                
                // Score Entry
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(round.scores) { playerScore in
                            PlayerScoreEntryCard(
                                playerScore: playerScore,
                                currentHole: currentHole,
                                score: binding(for: playerScore.id, in: $scores),
                                holeInfo: currentHoleInfo
                            )
                        }
                    }
                    .padding()
                }
                
                // Navigation Buttons
                HStack(spacing: 16) {
                    Button(action: previousHole) {
                        Label("Previous", systemImage: "chevron.left")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(currentHole == 1)
                    
                    Button(action: nextHole) {
                        Label("Next", systemImage: "chevron.right")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(currentHole == (course?.holes.count ?? 18))
                }
                .padding()
            }
            .navigationTitle("Quick Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        saveScores()
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadCurrentScores()
        }
    }
    
    private func binding(for playerId: UUID, in dict: Binding<[UUID: Int]>) -> Binding<Int> {
        Binding(
            get: { dict.wrappedValue[playerId] ?? 0 },
            set: { dict.wrappedValue[playerId] = $0 }
        )
    }
    
    private func loadCurrentScores() {
        for playerScore in round.scores {
            if let holeScore = playerScore.holeScores.first(where: { $0.holeNumber == currentHole }) {
                scores[playerScore.id] = holeScore.grossScore
            }
        }
    }
    
    private func saveCurrentHoleScores() {
        for playerScore in round.scores {
            let score = scores[playerScore.id] ?? 0
            
            if let existingScore = playerScore.holeScores.first(where: { $0.holeNumber == currentHole }) {
                existingScore.grossScore = score
            } else if score > 0 {
                let holeScore = HoleScore(
                    holeNumber: currentHole,
                    grossScore: score
                )
                holeScore.playerScore = playerScore
                holeScore.hole = currentHoleInfo
                playerScore.holeScores.append(holeScore)
            }
        }
    }
    
    private func previousHole() {
        saveCurrentHoleScores()
        currentHole = max(1, currentHole - 1)
        loadCurrentScores()
    }
    
    private func nextHole() {
        saveCurrentHoleScores()
        currentHole = min(course?.holes.count ?? 18, currentHole + 1)
        loadCurrentScores()
    }
    
    private func saveScores() {
        saveCurrentHoleScores()
        for playerScore in round.scores {
            playerScore.updateTotalScores()
        }
    }
}
