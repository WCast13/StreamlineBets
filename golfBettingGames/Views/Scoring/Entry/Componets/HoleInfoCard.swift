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

// MARK: - HoleInfoCard Preview
#Preview("Par 3") {
    HoleInfoCard(
        hole: Hole(
            number: 17,
            par: 3,
            handicap: 15,
            distance: 165
        )
    )
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

#Preview("Par 4") {
    HoleInfoCard(
        hole: Hole(
            number: 1,
            par: 4,
            handicap: 7,
            distance: 425
        )
    )
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

#Preview("Par 5") {
    HoleInfoCard(
        hole: Hole(
            number: 5,
            par: 5,
            handicap: 1,
            distance: 575
        )
    )
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

#Preview("Multiple Holes") {
    VStack(spacing: 16) {
        Text("Hole Information Examples")
            .font(.headline)
            .padding(.top)
        
        // Short Par 3
        VStack(alignment: .leading) {
            Text("Island Green")
                .font(.caption)
                .foregroundColor(.secondary)
            HoleInfoCard(
                hole: Hole(
                    number: 12,
                    par: 3,
                    handicap: 18,
                    distance: 137
                )
            )
        }
        
        // Long Par 4
        VStack(alignment: .leading) {
            Text("Dogleg Right")
                .font(.caption)
                .foregroundColor(.secondary)
            HoleInfoCard(
                hole: Hole(
                    number: 9,
                    par: 4,
                    handicap: 3,
                    distance: 468
                )
            )
        }
        
        // Reachable Par 5
        VStack(alignment: .leading) {
            Text("Risk/Reward")
                .font(.caption)
                .foregroundColor(.secondary)
            HoleInfoCard(
                hole: Hole(
                    number: 13,
                    par: 5,
                    handicap: 11,
                    distance: 510
                )
            )
        }
        
        Spacer()
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
