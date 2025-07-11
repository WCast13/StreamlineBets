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
    
    private var scoreDiff: Int {
        guard let par = par else { return 0 }
        return score - par
    }
    
    private var scoreColor: Color {
        guard let par = par else { return .primary }
        switch scoreDiff {
        case ..<(-1): return Color(red: 0.0, green: 0.6, blue: 0.0) // Eagle or better - dark green
        case -1: return .green // Birdie
        case 0: return .primary // Par
        case 1: return .orange // Bogey
        default: return .red // Double bogey or worse
        }
    }
    
    private var scoreBackground: Color? {
        guard let par = par else { return nil }
        if isCurrentHole {
            return Color.accentColor.opacity(0.2)
        }
        switch scoreDiff {
        case ..<(-1): return Color.green.opacity(0.15) // Eagle
        case -1: return nil // Birdie - no background
        default: return nil
        }
    }
    
    var body: some View {
        Text("\(score)")
            .frame(width: 30)
            .font(.caption)
            .fontWeight(isCurrentHole ? .bold : .medium)
            .foregroundColor(scoreColor)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(scoreBackground ?? Color.clear)
                    .padding(.horizontal, 2)
            )
    }
}