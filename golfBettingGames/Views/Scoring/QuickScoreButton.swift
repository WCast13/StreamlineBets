//
//  QuickScoreButton.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/7/25.
//


import SwiftUI

struct QuickScoreButton: View {
    let round: Round
    var size: ButtonSize = .regular
    
    enum ButtonSize {
        case small, regular, large
        
        var iconSize: Font {
            switch self {
            case .small: return .title3
            case .regular: return .title2
            case .large: return .largeTitle
            }
        }
        
        var textSize: Font {
            switch self {
            case .small: return .caption2
            case .regular: return .caption
            case .large: return .subheadline
            }
        }
        
        var padding: CGFloat {
            switch self {
            case .small: return 8
            case .regular: return 12
            case .large: return 16
            }
        }
    }
    
    @State private var showingLiveScoring = false
    
    private var buttonLabel: String {
        if round.holesPlayed == 0 {
            return "Start Scoring"
        } else {
            return "Continue"
        }
    }
    
    var body: some View {
        Button(action: { showingLiveScoring = true }) {
            VStack(spacing: 4) {
                Image(systemName: "flag.circle.fill")
                    .font(size.iconSize)
                
                Text(buttonLabel)
                    .font(size.textSize)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .padding(size.padding)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color.orange, Color.orange.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .shadow(color: Color.orange.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .fullScreenCover(isPresented: $showingLiveScoring) {
            LiveScoringView(round: round)
        }
    }
}

// Floating Action Button variant
struct FloatingScoreButton: View {
    let round: Round
    
    var body: some View {
        QuickScoreButton(round: round, size: .large)
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    VStack(spacing: 20) {
        QuickScoreButton(
            round: Round(
                roundNumber: 1,
                betAmount: 20,
                roundType: .full18
            ),
            size: .small
        )
        
        QuickScoreButton(
            round: Round(
                roundNumber: 1,
                betAmount: 20,
                roundType: .full18
            ),
            size: .regular
        )
        
        QuickScoreButton(
            round: Round(
                roundNumber: 1,
                betAmount: 20,
                roundType: .full18
            ),
            size: .large
        )
    }
    .padding()
}
