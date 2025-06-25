//
//  ActiveRoundsList.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/24/25.
//

import SwiftUI

// MARK: - ActiveRoundsList.swift
struct ActiveRoundsList: View {
    let rounds: [Round]
    @Binding var selectedRound: Round?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(rounds) { round in
                    ActiveRoundCard(round: round) {
                        selectedRound = round
                    }
                }
            }
            .padding()
        }
    }
}
