//
//  CompactHoleInfoView.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/15/25.
//

import SwiftUI
import SwiftData

struct CompactHoleInfoView: View {
    let currentHole: Int
    let totalHoles: Int
    let holeNumber: Int
    let hole: Hole?
    
    // Design configuration
    private let compactMode: Bool
    
    init(currentHole: Int, totalHoles: Int, holeNumber: Int, hole: Hole?, compactMode: Bool = true) {
        self.currentHole = currentHole
        self.totalHoles = totalHoles
        self.holeNumber = holeNumber
        self.hole = hole
        self.compactMode = compactMode
    }
    
    var body: some View {
        if compactMode {
            compactLayout
        } else {
            expandedLayout
        }
    }
    
    // MARK: - Compact Layout
    private var compactLayout: some View {
        VStack(alignment: .center, spacing: 4) {
            // Top row: Hole number with progress dots
            
            Text("Hole \(holeNumber)")
                .fontWeight(.bold)
            
            // Bottom row: Hole details
            if let hole = hole {
                HStack(spacing: 20) {
                    HoleStatView(label: "PAR", value: "\(hole.par)", color: .primary)
                    
                    Divider()
                        .frame(height: 30)
                    
                    HoleStatView(label: "YDS", value: "\(hole.distance)", color: .primary)
                    
                    Divider()
                        .frame(height: 30)
                    
                    HoleStatView(label: "HCP", value: "\(hole.handicap)", color: .primary)
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 4)
        .cornerRadius(10)
    }
    
    // MARK: - Expanded Layout
    private var expandedLayout: some View {
        VStack(spacing: 16) {
            // Header with hole info
            VStack(spacing: 8) {
                Text("Hole \(holeNumber)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Progress dots
                HStack(spacing: 5) {
                    ForEach(1...totalHoles, id: \.self) { hole in
                        Circle()
                            .fill(hole <= currentHole ? Color.accentColor : Color.gray.opacity(0.3))
                            .frame(width: hole == currentHole ? 8 : 6,
                                   height: hole == currentHole ? 8 : 6)
                            .animation(.easeInOut(duration: 0.2), value: currentHole)
                    }
                }
                
                Text("\(currentHole) of \(totalHoles)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Hole details
            if let hole = hole {
                HStack(spacing: 30) {
                    VStack {
                        Text("PAR")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(hole.par)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(parColor(for: hole.par))
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
                            .foregroundColor(handicapColor(for: hole.handicap))
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .cornerRadius(12)
    }
    
    // MARK: - Helper Views
    private struct HoleStatView: View {
        let label: String
        let value: String
        let color: Color
        
        var body: some View {
            VStack(spacing: 4) {
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func parColor(for par: Int) -> Color {
        switch par {
        case 3: return .blue
        case 4: return .primary
        case 5: return .green
        default: return .primary
        }
    }
    
    private func handicapColor(for handicap: Int) -> Color {
        switch handicap {
        case 1...6: return .red
        case 7...12: return .orange
        case 13...18: return .green
        default: return .primary
        }
    }
}

// MARK: - Ultra Compact Variant
struct UltraCompactHoleInfoView: View {
    let currentHole: Int
    let totalHoles: Int
    let holeNumber: Int
    let hole: Hole?
    
    var body: some View {
        HStack(spacing: 16) {
            // Hole number and progress
                Text("HOLE \(holeNumber)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
         
            
            if let hole = hole {
                // Compact stats
                HStack(spacing: 12) {
                    Text("Par \(hole.par)")
                        .font(.footnote)
                        .fontWeight(.medium)
                    
                    Text("\(hole.distance)y")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    Text("H\(hole.handicap)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .cornerRadius(8)
    }
}

// MARK: - Adaptive Hole Info View
struct AdaptiveHoleInfoView: View {
    let currentHole: Int
    let totalHoles: Int
    let holeNumber: Int
    let hole: Hole?
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    private var isUltraCompact: Bool {
        verticalSizeClass == .compact ||
        (horizontalSizeClass == .compact && UIDevice.current.userInterfaceIdiom == .phone)
    }
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact && verticalSizeClass != .compact
    }
    
    var body: some View {
        if isUltraCompact {
            UltraCompactHoleInfoView(
                currentHole: currentHole,
                totalHoles: totalHoles,
                holeNumber: holeNumber,
                hole: hole
            )
        } else {
            CompactHoleInfoView(
                currentHole: currentHole,
                totalHoles: totalHoles,
                holeNumber: holeNumber,
                hole: hole,
                compactMode: isCompact
            )
        }
    }
}

// MARK: - Horizontal Layout for iPad
struct HorizontalHoleInfoView: View {
    let currentHole: Int
    let totalHoles: Int
    let holeNumber: Int
    let hole: Hole?
    
    var body: some View {
        HStack(spacing: 20) {
            // Left: Hole number and progress
            VStack(alignment: .leading, spacing: 8) {
                Text("Hole \(holeNumber)")
                    .font(.title3)
                    .fontWeight(.bold)
                
                HStack(spacing: 4) {
                    ForEach(1...min(totalHoles, 18), id: \.self) { hole in
                        Circle()
                            .fill(hole <= currentHole ? Color.accentColor : Color.gray.opacity(0.3))
                            .frame(width: hole == currentHole ? 8 : 6,
                                   height: hole == currentHole ? 8 : 6)
                    }
                }
                
                Text("\(currentHole) of \(totalHoles)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
                .frame(height: 60)
            
            // Right: Hole details
            if let hole = hole {
                HStack(spacing: 30) {
                    VStack {
                        Text("PAR")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(hole.par)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(parColor(for: hole.par))
                    }
                    
                    VStack {
                        Text("YARDS")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(hole.distance)")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    
                    VStack {
                        Text("HANDICAP")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(hole.handicap)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(handicapColor(for: hole.handicap))
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .cornerRadius(10)
    }
    
    private func parColor(for par: Int) -> Color {
        switch par {
        case 3: return .blue
        case 4: return .primary
        case 5: return .green
        default: return .primary
        }
    }
    
    private func handicapColor(for handicap: Int) -> Color {
        switch handicap {
        case 1...6: return .red
        case 7...12: return .orange
        case 13...18: return .green
        default: return .primary
        }
    }
}
// MARK: - Previews
#Preview("Adaptive View - iPhone") {
    AdaptiveHoleInfoView(
        currentHole: 7,
        totalHoles: 18,
        holeNumber: 7,
        hole: Hole(number: 7, par: 4, handicap: 5, distance: 385)
    )
    .padding()
    .previewDevice("iPhone 15 Pro")
}

#Preview("Adaptive View - iPad") {
    VStack(spacing: 20) {
        AdaptiveHoleInfoView(
            currentHole: 12,
            totalHoles: 18,
            holeNumber: 12,
            hole: Hole(number: 12, par: 4, handicap: 8, distance: 445)
        )
        
        HorizontalHoleInfoView(
            currentHole: 12,
            totalHoles: 18,
            holeNumber: 12,
            hole: Hole(number: 12, par: 4, handicap: 8, distance: 445)
        )
    }
    .padding()
    .previewDevice("iPad Pro (11-inch)")
}

#Preview("All Variants") {
    ScrollView {
        VStack(spacing: 20) {
            Text("All Hole Info Variants")
                .font(.headline)
            
            Group {
                Text("Ultra Compact").font(.caption).foregroundColor(.secondary)
                UltraCompactHoleInfoView(
                    currentHole: 3,
                    totalHoles: 18,
                    holeNumber: 3,
                    hole: Hole(number: 3, par: 3, handicap: 15, distance: 165)
                )
            }
            
            Group {
                Text("Compact").font(.caption).foregroundColor(.secondary)
                CompactHoleInfoView(
                    currentHole: 7,
                    totalHoles: 18,
                    holeNumber: 7,
                    hole: Hole(number: 7, par: 4, handicap: 5, distance: 385),
                    compactMode: true
                )
            }
            
            Group {
                Text("Expanded").font(.caption).foregroundColor(.secondary)
                CompactHoleInfoView(
                    currentHole: 13,
                    totalHoles: 18,
                    holeNumber: 13,
                    hole: Hole(number: 13, par: 5, handicap: 1, distance: 575),
                    compactMode: false
                )
            }
            
            Group {
                Text("Horizontal (iPad)").font(.caption).foregroundColor(.secondary)
                HorizontalHoleInfoView(
                    currentHole: 17,
                    totalHoles: 18,
                    holeNumber: 17,
                    hole: Hole(number: 17, par: 3, handicap: 17, distance: 155)
                )
            }
        }
        .padding()
    }
}

#Preview("Compact Mode - Various Holes") {
    VStack(spacing: 16) {
        Text("Compact Hole Info Views")
            .font(.headline)
        
        CompactHoleInfoView(
            currentHole: 1,
            totalHoles: 18,
            holeNumber: 1,
            hole: Hole(number: 1, par: 4, handicap: 7, distance: 425),
            compactMode: true
        )
        
        CompactHoleInfoView(
            currentHole: 5,
            totalHoles: 9,
            holeNumber: 5,
            hole: Hole(number: 5, par: 3, handicap: 15, distance: 165),
            compactMode: true
        )
        
        CompactHoleInfoView(
            currentHole: 13,
            totalHoles: 18,
            holeNumber: 13,
            hole: Hole(number: 13, par: 5, handicap: 1, distance: 575),
            compactMode: true
        )
    }
    .padding()
}

#Preview("Ultra Compact Mode") {
    VStack(spacing: 12) {
        Text("Ultra Compact Views")
            .font(.headline)
        
        UltraCompactHoleInfoView(
            currentHole: 1,
            totalHoles: 18,
            holeNumber: 1,
            hole: Hole(number: 1, par: 4, handicap: 7, distance: 425)
        )
        
        UltraCompactHoleInfoView(
            currentHole: 9,
            totalHoles: 9,
            holeNumber: 9,
            hole: Hole(number: 9, par: 5, handicap: 3, distance: 540)
        )
        
        UltraCompactHoleInfoView(
            currentHole: 17,
            totalHoles: 18,
            holeNumber: 17,
            hole: Hole(number: 17, par: 3, handicap: 17, distance: 155)
        )
    }
    .padding()
}

#Preview("Expanded Mode") {
    CompactHoleInfoView(
        currentHole: 7,
        totalHoles: 18,
        holeNumber: 7,
        hole: Hole(number: 7, par: 4, handicap: 5, distance: 385),
        compactMode: false
    )
    .padding()
}
