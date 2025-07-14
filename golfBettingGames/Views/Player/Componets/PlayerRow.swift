// Views/Player/Components/PlayerRowView.swift
import SwiftUI
import SwiftData

struct PlayerRowView: View {
    let player: Player
    
    // Configuration options
    var showHandicap: Bool = true
    var showCourseHandicap: Bool = false
    var showWinnings: Bool = false
    var showRemoveButton: Bool = false
    var showChevron: Bool = true
    
    // Optional data for calculations
    var game: Game? = nil
    var winnings: Double? = nil
    var onRemove: (() -> Void)? = nil
    
    private var courseHandicap: Int? {
        guard let game = game else { return nil }
        return player.courseHandicap(
            courseRating: game.effectiveRating,
            slopeRating: Double(game.effectiveSlope),
            par: game.par
        )
    }
    
    var body: some View {
        HStack {
            // Player Avatar
            Circle()
                .fill(Color.accentColor.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(player.name.prefix(1).uppercased())
                        .font(.headline)
                        .foregroundColor(.accentColor)
                )
            
            // Player Info
            VStack(alignment: .leading, spacing: 4) {
                Text(player.name)
                    .font(.body)
                
                if showHandicap || showCourseHandicap {
                    HStack(spacing: 12) {
                        if showHandicap {
                            Label("\(player.handicapIndex, specifier: "%.1f")",
                                  systemImage: "figure.golf")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if showCourseHandicap, let ch = courseHandicap {
                            Text("CH: \(ch)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.secondary.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Right side content
            HStack(spacing: 12) {
                if showWinnings, let winnings = winnings {
                    Text(formatCurrency(winnings))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(winnings >= 0 ? .green : .red)
                }
                
                if showRemoveButton, let onRemove = onRemove {
                    Button(action: onRemove) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .imageScale(.medium)
                    }
                }
                
                if showChevron && !showRemoveButton {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

// MARK: - Convenience Extensions
extension PlayerRowView {
    // For basic player list
    static func basic(_ player: Player) -> PlayerRowView {
        PlayerRowView(player: player)
    }
    
    // For round setup with course handicap
    static func forRound(_ player: Player, game: Game, onRemove: @escaping () -> Void) -> PlayerRowView {
        PlayerRowView(
            player: player,
            showCourseHandicap: true,
            showRemoveButton: true,
            showChevron: false,
            game: game,
            onRemove: onRemove
        )
    }
    
    // For game details with winnings
    static func withWinnings(_ player: Player, winnings: Double) -> PlayerRowView {
        PlayerRowView(
            player: player,
            showWinnings: true,
            winnings: winnings
        )
    }
}
