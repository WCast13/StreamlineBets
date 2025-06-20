//
//  PlayerSelectionView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/19/25.
//

// MARK: - PlayerSelectionRow.swift
import SwiftUI

struct PlayerSelectionRow: View {
    let player: Player
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(player.name)
                    .font(.body)
                
                Text("Handicap: \(player.handicapIndex, specifier: "%.1f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.accentColor)
                    .imageScale(.large)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }
}
