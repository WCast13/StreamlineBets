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
            
            // Score Selection - Large buttons for easy tapping
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                ForEach(1...10, id: \.self) { num in
                    Button(action: {
                        score = num
                        // Haptic feedback
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }) {
                        Text("\(num)")
                            .font(.title2)
                            .fontWeight(score == num ? .bold : .medium)
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(score == num ? Color.accentColor : Color(UIColor.tertiarySystemBackground))
                            )
                            .foregroundColor(score == num ? .white : .primary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(score == num ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Net Score Display
            if score > 0 && strokesOnHole > 0 {
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
