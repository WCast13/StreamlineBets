//
//  HoleProgressView.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/7/25.
//


import SwiftUI
import SwiftData

struct HoleProgressView: View {
    let currentHole: Int
    let totalHoles: Int
    let holeNumber: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Hole \(holeNumber)")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Progress dots
            HStack(spacing: 6) {
                ForEach(1...totalHoles, id: \.self) { hole in
                    Circle()
                        .fill(hole <= currentHole ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(width: hole == currentHole ? 10 : 8,
                               height: hole == currentHole ? 10 : 8)
                        .animation(.easeInOut(duration: 0.2), value: currentHole)
                }
            }
            
            Text("\(currentHole) of \(totalHoles)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}