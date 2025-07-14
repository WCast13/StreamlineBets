//
//  HoleInfoCard.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/7/25.
//


import SwiftUI
import SwiftData

struct HoleInfoCard: View {
    let hole: Hole
    
    var body: some View {
        HStack(spacing: 30) {
            VStack {
                Text("PAR")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(hole.par)")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            VStack {
                Text("YARDS")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(hole.distance)")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            VStack {
                Text("HANDICAP")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(hole.handicap)")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(12)
    }
}