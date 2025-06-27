//
//  PlayerScorecardView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/27/25.
//


import SwiftUI
import SwiftData

struct PlayerScorecardView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var playerScore: PlayerScore
    let round: Round
    
    @State private var editingHole: Int?
    
    private var course: Course? {
        round.game?.course
    }
    
    private var player: Player? {
        playerScore.player
    }
    
    private var courseHandicap: Int {
        guard let player = player,
              let game = round.game else { return 0 }
        
        return player.courseHandicap(
            courseRating: game.effectiveRating,
            slopeRating: Double(game.effectiveSlope),
            par: game.par
        )
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Player Info Card
                    PlayerInfoCard(
                        player: player,
                        courseHandicap: courseHandicap,
                        totalScore: playerScore.score
                    )
                    
                    // Front 9
                    ScorecardSection(
                        title: "Front 9",
                        holes: 1...9,
                        course: course,
                        playerScore: playerScore,
                        courseHandicap: courseHandicap,
                        editingHole: $editingHole
                    )
                    
                    // Back 9
                    if let course = course, course.holes.count == 18 {
                        ScorecardSection(
                            title: "Back 9",
                            holes: 10...18,
                            course: course,
                            playerScore: playerScore,
                            courseHandicap: courseHandicap,
                            editingHole: $editingHole
                        )
                    }
                    
                    // Summary
                    ScorecardSummary(playerScore: playerScore, course: course)
                }
                .padding()
            }
            .navigationTitle(player?.name ?? "Player Scorecard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        playerScore.updateTotalScores()
                        dismiss()
                    }
                }
            }
//            .sheet(item: $editingHole) { holeNumber in
//                HoleScoreEditView(
//                    playerScore: playerScore,
//                    holeNumber: holeNumber,
//                    hole: course?.holes.first(where: { $0.number == holeNumber }),
//                    courseHandicap: courseHandicap
//                )
//            }
        }
    }
}
