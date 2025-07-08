//
//  LiveScoreCard.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/7/25.
//


import SwiftUI
import SwiftData

struct LiveScoreCard: View {
    @Bindable var playerScore: PlayerScore
    @Binding var score: Int
    let holeInfo: Hole?
    let courseHandicap: Int
    
    private var strokesOnHole: Int {
        guard let hole = holeInfo else { return 0 }
        return courseHandicap >= hole.handicap ? 1 : 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Player Info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(playerScore.player?.name ?? "Unknown")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 12) {
                        Text("CH: \(courseHandicap)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if strokesOnHole > 0 {
                            Label("\(strokesOnHole) stroke(s)", systemImage: "star.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Spacer()
                
                // Current round stats
                if playerScore.score > 0 {
                    VStack(alignment: .trailing) {
                        Text("Total: \(playerScore.score)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Score Entry with Stepper - CHANGED FROM BUTTON GRID
            VStack(spacing: 12) {
                HStack {
                    Text("Gross Score")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Score display and stepper
                    HStack(spacing: 16) {
                        Button(action: {
                            if score > 1 {
                                score -= 1
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundColor(score > 1 ? .accentColor : .gray)
                        }
                        .disabled(score <= 1)
                        
                        Text("\(score)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .frame(minWidth: 50)
                            .foregroundColor(.primary)
                        
                        Button(action: {
                            if score < 12 {
                                score += 1
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(score < 12 ? .accentColor : .gray)
                        }
                        .disabled(score >= 12)
                    }
                }
                
                // Score relative to par indicator - NEW
                if let hole = holeInfo {
                    HStack {
                        Spacer()
                        ScoreToPar(score: score, par: hole.par)
                        Spacer()
                    }
                }
            }
            
            // Net Score Display
            if strokesOnHole > 0 {
                HStack {
                    Text("Net Score: \(score - strokesOnHole)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// Helper view to show score relative to par
struct ScoreToPar: View {
    let score: Int
    let par: Int
    
    private var difference: Int { score - par }
    
    private var label: String {
        switch difference {
        case ..<(-2): return "Eagle or better"
        case -2: return "Eagle"
        case -1: return "Birdie"
        case 0: return "Par"
        case 1: return "Bogey"
        case 2: return "Double Bogey"
        case 3: return "Triple Bogey"
        default: return "+\(difference)"
        }
    }
    
    private var color: Color {
        switch difference {
        case ..<0: return .green
        case 0: return .primary
        case 1: return .orange
        default: return .red
        }
    }
    
    var body: some View {
        Text(label)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .cornerRadius(8)
    }
}
