//
//  GameRowView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/20/25.
//

import SwiftUI

struct GameRowView: View {
    let game: Game
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(game.name)
                .font(.headline)
            
            HStack {
                Text(game.gameType.description)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.2))
                    .cornerRadius(4)
                
                Text(game.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
