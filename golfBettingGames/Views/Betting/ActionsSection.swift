//
//  ActionsSection.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/25/25.
//

import SwiftUI
import SwiftData

// MARK: - ActionsSection.swift
struct ActionsSection: View {
    let round: Round
    @Binding var showingWinningsCalculator: Bool
    @Binding var showingDeleteAlert: Bool
    
    var body: some View {
        Section {
            Button(action: { showingWinningsCalculator = true }) {
                Label("Adjust Winnings", systemImage: "dollarsign.circle")
            }
            
            Button(action: { showingDeleteAlert = true }) {
                Label("Delete Round", systemImage: "trash")
                    .foregroundColor(.red)
            }
        }
    }
}
