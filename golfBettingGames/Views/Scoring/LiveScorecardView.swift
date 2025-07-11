//
//  LiveScorecardView.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/11/25.
//


import SwiftUI
import SwiftData

struct LiveScorecardView: View {
    let round: Round
    let currentHoleNumber: Int
    @Binding var scores: [UUID: Int]
    
    private var course: Course? { round.game?.course }
    
    private var holes: [Hole] {
        course?.sortedHoles ?? []
    }
    
    private var front9Holes: [Hole] {
        holes.filter { $0.number <= 9 }
    }
    
    private var back9Holes: [Hole] {
        holes.filter { $0.number > 9 }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("SCORECARD")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let courseName = round.game?.courseName {
                    Text(courseName)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 12)
            .background(Color(UIColor.tertiarySystemBackground))
            
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Hole Numbers Row
                    HStack(spacing: 0) {
                        Text("HOLE")
                            .frame(width: 60, alignment: .leading)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                        
                        // Front 9
                        ForEach(1...9, id: \.self) { hole in
                            Text("\(hole)")
                                .frame(width: 30)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(currentHoleNumber == hole ? .white : .primary)
                                .background(
                                    currentHoleNumber == hole ?
                                    Circle()
                                        .fill(Color.accentColor)
                                        .frame(width: 24, height: 24) : nil
                                )
                        }
                        
                        Text("OUT")
                            .frame(width: 40)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Divider()
                            .frame(width: 1)
                            .padding(.horizontal, 4)
                        
                        // Back 9
                        ForEach(10...18, id: \.self) { hole in
                            Text("\(hole)")
                                .frame(width: 30)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(currentHoleNumber == hole ? .white : .primary)
                                .background(
                                    currentHoleNumber == hole ?
                                    Circle()
                                        .fill(Color.accentColor)
                                        .frame(width: 24, height: 24) : nil
                                )
                        }
                        
                        Text("IN")
                            .frame(width: 40)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text("TOT")
                            .frame(width: 40)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    .background(Color(UIColor.secondarySystemBackground))
                    
                    // Par Row
                    HStack(spacing: 0) {
                        Text("PAR")
                            .frame(width: 80, alignment: .leading)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                        
                        // Front 9 pars
                        ForEach(front9Holes) { hole in
                            Text("\(hole.par)")
                                .frame(width: 30)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        // Fill empty holes
                        ForEach(front9Holes.count..<9, id: \.self) { _ in
                            Text("-")
                                .frame(width: 30)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("\(course?.front9Par ?? 0)")
                            .frame(width: 40)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Divider()
                            .frame(width: 1)
                            .padding(.horizontal, 4)
                        
                        // Back 9 pars
                        ForEach(back9Holes) { hole in
                            Text("\(hole.par)")
                                .frame(width: 30)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        // Fill empty holes
                        ForEach(back9Holes.count..<9, id: \.self) { _ in
                            Text("-")
                                .frame(width: 30)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("\(course?.back9Par ?? 0)")
                            .frame(width: 40)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("\(course?.par ?? 0)")
                            .frame(width: 40)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // Player Rows
                    ForEach(round.scores.sorted(by: {
                        ($0.player?.name ?? "") < ($1.player?.name ?? "")
                    })) { playerScore in
                        PlayerScorecardRow(
                            playerScore: playerScore,
                            currentHoleNumber: currentHoleNumber,
                            scores: $scores,
                            front9Holes: front9Holes,
                            back9Holes: back9Holes
                        )
                        
                        Divider()
                    }
                }
            }
            .font(.system(.body, design: .monospaced))
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
