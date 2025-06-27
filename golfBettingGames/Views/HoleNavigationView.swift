//
//  HoleNavigationView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/27/25.
//


import SwiftUI
import SwiftData

// MARK: - HoleNavigationView
struct HoleNavigationView: View {
    @Binding var currentHole: Int
    let totalHoles: Int
    let holeInfo: Hole?
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Hole \(currentHole)")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if let hole = holeInfo {
                HStack(spacing: 20) {
                    Label("Par \(hole.par)", systemImage: "flag.fill")
//                    Label("\(hole.yardage) yds", systemImage: "location.fill")
                    Label("Hdcp \(hole.handicap)", systemImage: "number.circle")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            
            // Hole dots indicator
            HStack(spacing: 4) {
                ForEach(1...totalHoles, id: \.self) { hole in
                    Circle()
                        .fill(hole == currentHole ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(width: hole == currentHole ? 8 : 6,
                               height: hole == currentHole ? 8 : 6)
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
    }
}
