//
//  RoundDetailsSection.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/19/25.
//

import SwiftUI

// MARK: - RoundDetailsSection.swift
struct RoundDetailsSection: View {
    @Binding var roundType: RoundType
    @Binding var roundNumber: Int
    @Binding var holeNumber: Int
    let game: Game
    
    var body: some View {
        Section("Round Details") {
            Picker("Round Type", selection: $roundType) {
                ForEach(RoundType.allCases, id: \.self) { type in
                    Text(type.description).tag(type)
                }
            }
            .onChange(of: roundType) { _, newValue in
                updateRoundNumber(for: newValue)
            }
            
            if roundType == .hole {
                Stepper("Hole Number: \(holeNumber)",
                       value: $holeNumber,
                       in: 1...18)
            }
            
            HStack {
                Text("Round #")
                Spacer()
                Text("\(roundNumber)")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func updateRoundNumber(for roundType: RoundType) {
        if roundType == .hole {
            let holeRounds = game.rounds.filter { $0.roundType == .hole }
            roundNumber = holeRounds.count + 1
        }
    }
}
