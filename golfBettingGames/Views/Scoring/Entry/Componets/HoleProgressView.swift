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

// MARK: - HoleProgressView Preview
#Preview("Beginning of Round") {
    VStack(spacing: 40) {
        // 18 holes - first hole
        HoleProgressView(
            currentHole: 1,
            totalHoles: 18,
            holeNumber: 1
        )
        
        // 9 holes - first hole
        HoleProgressView(
            currentHole: 1,
            totalHoles: 9,
            holeNumber: 1
        )
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

#Preview("Middle of Round") {
    VStack(spacing: 40) {
        // 18 holes - hole 10
        HoleProgressView(
            currentHole: 10,
            totalHoles: 18,
            holeNumber: 10
        )
        
        // 9 holes - hole 5
        HoleProgressView(
            currentHole: 5,
            totalHoles: 9,
            holeNumber: 5
        )
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

#Preview("End of Round") {
    VStack(spacing: 40) {
        // 18 holes - final hole
        HoleProgressView(
            currentHole: 18,
            totalHoles: 18,
            holeNumber: 18
        )
        
        // 9 holes - final hole
        HoleProgressView(
            currentHole: 9,
            totalHoles: 9,
            holeNumber: 9
        )
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

#Preview("Different Round Types") {
    VStack(spacing: 40) {
        Text("Different Round Types")
            .font(.headline)
        
        // Single hole
        VStack {
            Text("Single Hole")
                .font(.caption)
                .foregroundColor(.secondary)
            HoleProgressView(
                currentHole: 1,
                totalHoles: 1,
                holeNumber: 17
            )
        }
        
        // Front 9
        VStack {
            Text("Front 9")
                .font(.caption)
                .foregroundColor(.secondary)
            HoleProgressView(
                currentHole: 7,
                totalHoles: 9,
                holeNumber: 7
            )
        }
        
        // Back 9
        VStack {
            Text("Back 9")
                .font(.caption)
                .foregroundColor(.secondary)
            HoleProgressView(
                currentHole: 4,
                totalHoles: 9,
                holeNumber: 13  // Back 9 starts at hole 10
            )
        }
        
        // Full 18
        VStack {
            Text("Full 18")
                .font(.caption)
                .foregroundColor(.secondary)
            HoleProgressView(
                currentHole: 15,
                totalHoles: 18,
                holeNumber: 15
            )
        }
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

#Preview("Interactive Progress") {
    struct InteractiveProgress: View {
        @State private var currentHole = 1
        let totalHoles = 18
        
        var body: some View {
            VStack(spacing: 20) {
                HoleProgressView(
                    currentHole: currentHole,
                    totalHoles: totalHoles,
                    holeNumber: currentHole
                )
                
                HStack(spacing: 20) {
                    Button(action: {
                        if currentHole > 1 {
                            currentHole -= 1
                        }
                    }) {
                        Label("Previous", systemImage: "chevron.left")
                    }
                    .buttonStyle(.bordered)
                    .disabled(currentHole == 1)
                    
                    Button(action: {
                        if currentHole < totalHoles {
                            currentHole += 1
                        }
                    }) {
                        Label("Next", systemImage: "chevron.right")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(currentHole == totalHoles)
                }
            }
            .padding()
        }
    }
    
    return InteractiveProgress()
        .background(Color(UIColor.systemGroupedBackground))
}

