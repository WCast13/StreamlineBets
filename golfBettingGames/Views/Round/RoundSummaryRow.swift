//
//  RoundSummaryRow.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/20/25.
//

import SwiftUI

struct RoundSummaryRow: View {
    let round: Round
    @State private var showingLiveScoring = false
    
    private var scoringProgress: (completed: Int, total: Int) {
        let totalHoles = round.roundType == .hole ? 1 : (round.roundType == .front9 || round.roundType == .back9 ? 9 : 18)
        let completedHoles = round.scores.first?.holeScores.count ?? 0
        return (completedHoles, totalHoles)
    }
    
    private var progressPercentage: Double {
        guard scoringProgress.total > 0 else { return 0 }
        return Double(scoringProgress.completed) / Double(scoringProgress.total)
    }
    
    var body: some View {
        HStack {
            // Round Info
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Round \(round.roundNumber)")
                        .font(.headline)
                    
                    if !round.isCompleted {
                        Label("In Progress", systemImage: "flag.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(6)
                    }
                }
                
                HStack {
                    if let holeNumber = round.holeNumber {
                        Text("Hole \(holeNumber)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text(round.roundType.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if !round.isCompleted && round.roundType != .hole {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text("\(scoringProgress.completed)/\(scoringProgress.total) holes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Progress Bar for incomplete rounds
                if !round.isCompleted && round.roundType != .hole {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.orange)
                                .frame(width: geometry.size.width * progressPercentage, height: 4)
                                .animation(.easeInOut(duration: 0.3), value: progressPercentage)
                        }
                    }
                    .frame(height: 4)
                }
            }
            
            Spacer()
            
            // Right Side - Bet Amount and Action
            VStack(alignment: .trailing, spacing: 6) {
                if round.isCompleted {
                    Text("$\(round.betAmount, specifier: "%.0f")")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(round.date.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Button(action: { showingLiveScoring = true }) {
                        VStack(spacing: 2) {
                            Image(systemName: "play.circle.fill")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                            
                            Text("Continue")
                                .font(.caption2)
                                .foregroundColor(.accentColor)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .fullScreenCover(isPresented: $showingLiveScoring) {
            LiveScoringView(round: round)
        }
    }
}

