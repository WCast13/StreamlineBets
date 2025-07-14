//
//  MatchStatusCell.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/14/25.
//


import SwiftUI
import SwiftData

struct MatchStatusCell: View {
    let hole: Int
    let matchStatus: (player1Up: Int, player2Up: Int)
    let isCurrentHole: Bool
    let hasScore: Bool
    
    private var statusText: String {
        if !hasScore { return "-" }
        
        if matchStatus.player1Up > 0 {
            return "\(matchStatus.player1Up)"
        } else if matchStatus.player2Up > 0 {
            return "\(matchStatus.player2Up)"
        } else {
            return "AS"
        }
    }
    
    private var statusColor: Color {
        if !hasScore { return .secondary }
        
        if matchStatus.player1Up > 0 {
            return .blue
        } else if matchStatus.player2Up > 0 {
            return .red
        } else {
            return .orange
        }
    }
    
    var body: some View {
        Text(statusText)
            .frame(width: 24, height: 14)
            .font(.system(size: 7, weight: isCurrentHole ? .bold : .medium))
            .foregroundColor(statusColor)
            .background(
                isCurrentHole ?
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.accentColor.opacity(0.15))
                    .padding(.horizontal, 1) : nil
            )
    }
}