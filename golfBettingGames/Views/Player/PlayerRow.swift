//
//  PlayerRow.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/20/25.
//

import SwiftUI

// MARK: - PlayerRow.swift
struct PlayerRow: View {
    let player: Player
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color.accentColor.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(player.name.prefix(1).uppercased())
                        .font(.headline)
                        .foregroundColor(.accentColor)
                )
            
            VStack(alignment: .leading) {
                Text(player.name)
                    .font(.headline)
                Text("Handicap: \(player.handicapIndex, specifier: "%.1f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
