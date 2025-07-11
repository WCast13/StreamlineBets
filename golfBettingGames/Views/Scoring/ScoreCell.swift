//
//  ScoreCell.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/11/25.
//

import SwiftUI
import SwiftData

struct ScoreCell: View {
    let score: Int
    let par: Int?
    let isCurrentHole: Bool
    let hasStroke: Bool // ADDED: New parameter for stroke indicator
    
    private var scoreDiff: Int {
        guard let par = par else { return 0 }
        return score - par
    }
    
    private var scoreColor: Color {
        guard let par = par else { return .primary }
        switch scoreDiff {
        case ..<(-1): return Color(red: 0.0, green: 0.6, blue: 0.0) // Eagle or better
        case -1: return .green // Birdie
        case 0: return .primary // Par
        case 1: return .orange // Bogey
        default: return .red // Double bogey or worse
        }
    }
    
    var body: some View {
        ZStack {
            
            Text("\(score)")
                .frame(width: 24, height: 16)
                .font(.system(size: 8, weight: isCurrentHole ? .bold : .medium))
                .foregroundColor(scoreColor)
                .background(
                    isCurrentHole ?
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.accentColor.opacity(0.15))
                        .padding(.horizontal, 1) : nil
                )
            
            // ADDED: Small dot indicator for strokes
            if hasStroke {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 3, height: 3)
                    .offset(x: 8, y: -6)
            }
        }
    }
}
