//
//  GameRowView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/20/25.
//

import SwiftUI

struct GameRowView: View {
    let game: Game
    
    private var incompleteRounds: Int {
        game.rounds.filter { !$0.isCompleted }.count
    }
    
    private var hasActiveRounds: Bool {
        incompleteRounds > 0
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(game.name)
                        .font(.headline)
                    
                    if hasActiveRounds {
                        Image(systemName: "flag.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                HStack(spacing: 12) {
                    Text(game.gameType.description)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.2))
                        .cornerRadius(4)
                    
                    Text(game.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if hasActiveRounds {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text("\(incompleteRounds) active")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .fontWeight(.medium)
                    }
                }
                
                HStack {
                    Label("\(game.players.count)", systemImage: "person.2")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(game.courseName)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            if hasActiveRounds {
                VStack {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    
                    Text("Active")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.vertical, 4)
    }
}



















