//
//  ScorecardSection.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/27/25.
//

import SwiftUI
import SwiftData

// MARK: - ScorecardSection
struct ScorecardSection: View {
    let title: String
    let holes: ClosedRange<Int>
    let course: Course?
    let playerScore: PlayerScore
    let courseHandicap: Int
    @Binding var editingHole: Int?
    
    private var sectionHoles: [Hole] {
        course?.holes.filter { holes.contains($0.number) }
            .sorted { $0.number < $1.number } ?? []
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            VStack(spacing: 0) {
                // Header
                HStack(spacing: 0) {
                    Text("Hole")
                        .frame(width: 50, alignment: .leading)
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    ForEach(holes, id: \.self) { hole in
                        Text("\(hole)")
                            .frame(width: 35)
                            .font(.caption)
                    }
                    
                    Text("Total")
                        .frame(width: 50)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                
                // Par Row
                HStack(spacing: 0) {
                    Text("Par")
                        .frame(width: 50, alignment: .leading)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(sectionHoles) { hole in
                        Text("\(hole.par)")
                            .frame(width: 35)
                            .font(.caption2)
                    }
                    
                    Text("\(sectionHoles.reduce(0) { $0 + $1.par })")
                        .frame(width: 50)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.vertical, 4)
                
                // Score Row
                HStack(spacing: 0) {
                    Text("Score")
                        .frame(width: 50, alignment: .leading)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(holes, id: \.self) { holeNum in
                        Button(action: { editingHole = holeNum }) {
                            if let holeScore = playerScore.holeScores.first(where: { $0.holeNumber == holeNum }) {
                                Text("\(holeScore.grossScore)")
                                    .frame(width: 35)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            } else {
                                Text("-")
                                    .frame(width: 35)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    
                    let total = holes.compactMap { holeNum in
                        playerScore.holeScores.first(where: { $0.holeNumber == holeNum })?.grossScore
                    }.reduce(0, +)
                    
                    Text(total > 0 ? "\(total)" : "-")
                        .frame(width: 50)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 8)
            }
            .font(.system(.body, design: .monospaced))
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
        }
    }
}
