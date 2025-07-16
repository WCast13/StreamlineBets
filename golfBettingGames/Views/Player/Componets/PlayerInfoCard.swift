//
//  PlayerInfoCard.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/27/25.
//


import SwiftUI
import SwiftData

// MARK: - PlayerInfoCard
struct PlayerInfoCard: View {
    let player: Player?
    let courseHandicap: Int
    let totalScore: Int
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(player?.name ?? "Unknown")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Handicap Index: \(player?.handicapIndex ?? 0, specifier: "%.1f")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("CH: \(courseHandicap)")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                    
                    Text("Course Handicap")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            HStack(spacing: 30) {
                StatView(label: "Gross", value: totalScore > 0 ? "\(totalScore)" : "-")
                StatView(label: "Net", value: totalScore > 0 ? "\(totalScore - courseHandicap)" : "-")
            }
        }
        .padding()
        .cornerRadius(12)
    }
}

