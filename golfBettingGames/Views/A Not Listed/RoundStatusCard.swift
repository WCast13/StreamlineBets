//
//  RoundStatusCard.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/7/25.
//


import SwiftUI
import SwiftData

struct RoundStatusCard: View {
    let round: Round
    @State private var showingLiveScoring = false
    
    private var holesCompleted: Int {
        guard let firstScore = round.scores.first else { return 0 }
        return firstScore.holeScores.count
    }
    
    private var totalHoles: Int {
        switch round.roundType {
        case .hole: return 1
        case .front9, .back9: return 9
        case .full18: return 18
        case .custom: return round.holesPlayed
        }
    }
    
    private var progressPercentage: Double {
        guard totalHoles > 0 else { return 0 }
        return Double(holesCompleted) / Double(totalHoles)
    }
    
    private var currentLeader: (player: Player?, score: Int)? {
        let validScores = round.scores.filter { $0.score > 0 }
        guard let lowestScore = validScores.min(by: { $0.netScore < $1.netScore }) else { return nil }
        return (lowestScore.player, lowestScore.netScore)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Round Status")
                        .font(.headline)
                    
                    if round.isCompleted {
                        Label("Completed", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Label("In Progress", systemImage: "flag.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                if !round.isCompleted {
                    QuickScoreButton(round: round, size: .small)
                }
            }
            
            // Progress Bar
            if !round.isCompleted && round.roundType != .hole {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("\(holesCompleted) of \(totalHoles) holes completed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(progressPercentage * 100))%")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.orange, Color.orange.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * progressPercentage, height: 8)
                                .animation(.easeInOut(duration: 0.3), value: progressPercentage)
                        }
                    }
                    .frame(height: 8)
                }
            }
            
            // Stats Grid
            HStack(spacing: 16) {
                StatCard(
                    title: "Players",
                    value: "\(round.scores.count)",
                    icon: "person.2.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Bet Amount",
                    value: "$\(Int(round.betAmount))",
                    icon: "dollarsign.circle.fill",
                    color: .green
                )
                
                if let leader = currentLeader {
                    StatCard(
                        title: "Leader",
                        value: leader.player?.name ?? "Unknown",
                        subtitle: "Net: \(leader.score)",
                        icon: "trophy.fill",
                        color: .orange
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct StatCard: View {
    let title: String
    let value: String
    var subtitle: String? = nil
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.headline)
                    .lineLimit(1)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}
