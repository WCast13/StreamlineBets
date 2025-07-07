//
//  ScoringTipView.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/7/25.
//


import SwiftUI

struct ScoringTipView: View {
    @State private var isVisible = true
    @AppStorage("hasSeenScoringTip") private var hasSeenTip = false
    
    var body: some View {
        if isVisible && !hasSeenTip {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.title2)
                        .foregroundColor(.yellow)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Quick Scoring Tip")
                            .font(.headline)
                        
                        Text("After creating a round, you'll automatically enter Live Scoring mode for easy hole-by-hole entry")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: dismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack(spacing: 16) {
                    Image(systemName: "1.circle.fill")
                        .foregroundColor(.accentColor)
                    Text("Create a round")
                        .font(.caption)
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(.secondary)
                    
                    Image(systemName: "flag.circle.fill")
                        .foregroundColor(.orange)
                    Text("Live scoring opens")
                        .font(.caption)
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(.secondary)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Track scores easily")
                        .font(.caption)
                }
                .font(.caption2)
            }
            .padding()
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
            )
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
    
    private func dismiss() {
        withAnimation {
            isVisible = false
            hasSeenTip = true
        }
    }
}

// Pulse Animation for New Users
struct PulsingView: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .opacity(isPulsing ? 0.8 : 1.0)
            .animation(
                Animation.easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

extension View {
    func pulseEffect() -> some View {
        modifier(PulsingView())
    }
}
