//
//  GameHistoryRow.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/8/25.
//


import SwiftData
import SwiftUI

// MARK: - GameHistoryRow
struct GameHistoryRow: View {
    let game: Game
    let player: Player
    
    private var playerWinnings: Double {
        game.totalForPlayer(player)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(game.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Text(game.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(game.courseName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Text(formatCurrency(playerWinnings))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(playerWinnings >= 0 ? .green : .red)
        }
        .padding(.vertical, 8)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}