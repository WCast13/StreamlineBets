// Views/Scoring/Scorecard/Components/ScorecardViewModel.swift
import SwiftUI
import SwiftData

// MARK: - Scorecard View Model
@Observable
class ScorecardViewModel {
    let round: Round
    let course: Course?
    
    var showingStrokeInfo = false
    var showingMatchPlayDetails = false
    
    var front9Holes: [Hole] {
        course?.holes.filter { $0.number <= 9 }.sorted { $0.number < $1.number } ?? []
    }
    
    var back9Holes: [Hole] {
        course?.holes.filter { $0.number > 9 }.sorted { $0.number < $1.number } ?? []
    }
    
    init(round: Round) {
        self.round = round
        self.course = round.game?.course
    }
    
    func courseHandicap(for player: Player?) -> Int {
        guard let player = player, let game = round.game else { return 0 }
        return player.courseHandicap(
            courseRating: game.effectiveRating,
            slopeRating: Double(game.effectiveSlope),
            par: game.par
        )
    }
    
    func getsStrokeOnHole(_ holeNumber: Int, for player: Player?) -> Bool {
        guard let player = player,
              let hole = course?.holes.first(where: { $0.number == holeNumber }) else { return false }
        return courseHandicap(for: player) >= hole.handicap
    }
}

// MARK: - Scorecard Header
struct ScorecardHeader: View {
    let viewModel: ScorecardViewModel
    let isCompact: Bool
    
    var body: some View {
        HStack {
            Text(isCompact ? "SCORES" : "SCORECARD")
                .font(.system(size: isCompact ? 10 : 12, weight: .bold))
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Info toggles
            HStack(spacing: 8) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.showingStrokeInfo.toggle()
                    }
                } label: {
                    Image(systemName: viewModel.showingStrokeInfo ? "info.circle.fill" : "info.circle")
                        .font(.system(size: isCompact ? 12 : 14))
                        .foregroundColor(.accentColor)
                }
                
                if viewModel.round.game?.gameType == .matchPlay {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.showingMatchPlayDetails.toggle()
                        }
                    } label: {
                        Image(systemName: viewModel.showingMatchPlayDetails ? "flag.2.crossed.fill" : "flag.2.crossed")
                            .font(.system(size: isCompact ? 12 : 14))
                            .foregroundColor(.accentColor)
                    }
                }
            }
            
            if let courseName = viewModel.round.game?.courseName {
                Text(courseName)
                    .font(.system(size: isCompact ? 9 : 10))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .frame(maxWidth: 150)
            }
        }
        .padding(.horizontal, isCompact ? 8 : 12)
        .padding(.vertical, isCompact ? 4 : 6)
        .background(Color(UIColor.tertiarySystemBackground))
    }
}

// MARK: - Scorecard Grid
struct ScorecardGrid: View {
    let viewModel: ScorecardViewModel
    let currentHoleNumber: Int?
    @Binding var scores: [UUID: Int]
    let isEditable: Bool
    let onScoreTap: ((PlayerScore, Int) -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            // Hole numbers row
            ScorecardHoleRow(
                viewModel: viewModel,
                currentHoleNumber: currentHoleNumber
            )
            
            // Par row
            ScorecardParRow(viewModel: viewModel)
            
            Divider()
            
            // Player scores
            ForEach(viewModel.round.scores.sorted(by: {
                ($0.player?.name ?? "") < ($1.player?.name ?? "")
            })) { playerScore in
                ScorecardPlayerRow(
                    playerScore: playerScore,
                    viewModel: viewModel,
                    currentHoleNumber: currentHoleNumber,
                    scores: $scores,
                    isEditable: isEditable,
                    onScoreTap: onScoreTap
                )
                
                Divider()
                    .opacity(0.5)
            }
            
            // Match play details if applicable
            if viewModel.round.game?.gameType == .matchPlay && 
               viewModel.showingMatchPlayDetails {
                MatchPlayDetailsSection(
                    viewModel: viewModel,
                    currentHoleNumber: currentHoleNumber
                )
            }
        }
    }
}

// MARK: - Scorecard Row Components
struct ScorecardHoleRow: View {
    let viewModel: ScorecardViewModel
    let currentHoleNumber: Int?
    
    var body: some View {
        HStack(spacing: 0) {
            Text("HOLE")
                .frame(width: 60, alignment: .leading)
                .font(.system(size: 10, weight: .semibold))
                .padding(.horizontal, 4)
            
            // Front 9
            ForEach(1...9, id: \.self) { hole in
                HoleNumberCell(
                    number: hole,
                    isCurrent: currentHoleNumber == hole
                )
            }
            
            Text("OUT")
                .frame(width: 36)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.blue)
            
            Divider()
                .frame(width: 1, height: 12)
                .padding(.horizontal, 4)
            
            // Back 9
            ForEach(10...18, id: \.self) { hole in
                HoleNumberCell(
                    number: hole,
                    isCurrent: currentHoleNumber == hole
                )
            }
            
            Text("IN")
                .frame(width: 36)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.blue)
            
            Text("TOT")
                .frame(width: 36)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.green)
        }
        .padding(.vertical, 4)
        .background(Color(UIColor.secondarySystemBackground))
    }
}

// MARK: - Supporting Components
struct HoleNumberCell: View {
    let number: Int
    let isCurrent: Bool
    
    var body: some View {
        Text("\(number)")
            .frame(width: 28)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(isCurrent ? .white : .primary)
            .background(
                isCurrent ?
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 20, height: 20) : nil
            )
    }
}

struct ScorecardScoreCell: View {
    let score: Int?
    let par: Int?
    let isCurrent: Bool
    let hasStroke: Bool
    let isEditable: Bool
    let onTap: (() -> Void)?
    
    var body: some View {
        Button(action: { onTap?() }) {
            ZStack {
                if let score = score {
                    Text("\(score)")
                        .frame(width: 28)
                        .font(.system(size: 10, weight: isCurrent ? .bold : .medium))
                        .foregroundColor(scoreColor(score: score, par: par))
                        .background(
                            isCurrent ?
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.accentColor.opacity(0.15))
                                .padding(.horizontal, 2) : nil
                        )
                } else {
                    Text("-")
                        .frame(width: 28)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                
                if hasStroke {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 4, height: 4)
                        .offset(x: 10, y: -8)
                }
            }
        }
        .disabled(!isEditable)
        .buttonStyle(.plain)
    }
    
    private func scoreColor(score: Int, par: Int?) -> Color {
        guard let par = par else { return .primary }
        let diff = score - par
        switch diff {
        case ..<(-1): return Color(red: 0.0, green: 0.6, blue: 0.0)
        case -1: return .green
        case 0: return .primary
        case 1: return .orange
        default: return .red
        }
    }
}

// MARK: - Additional Missing Components

struct ScorecardParRow: View {
    let viewModel: ScorecardViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            Text("PAR")
                .frame(width: 60, alignment: .leading)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
            
            // Front 9 pars
            ForEach(viewModel.front9Holes) { hole in
                Text("\(hole.par)")
                    .frame(width: 28)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            // Fill empty holes if less than 9
            ForEach(viewModel.front9Holes.count..<9, id: \.self) { _ in
                Text("-")
                    .frame(width: 28)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            // Front 9 total
            Text("\(viewModel.course?.front9Par ?? 0)")
                .frame(width: 36)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
            
            Divider()
                .frame(width: 1, height: 10)
                .padding(.horizontal, 4)
            
            // Back 9 pars
            ForEach(viewModel.back9Holes) { hole in
                Text("\(hole.par)")
                    .frame(width: 28)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            // Fill empty holes if less than 9
            ForEach(viewModel.back9Holes.count..<9, id: \.self) { _ in
                Text("-")
                    .frame(width: 28)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            // Back 9 total
            Text("\(viewModel.course?.back9Par ?? 0)")
                .frame(width: 36)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
            
            // Total par
            Text("\(viewModel.course?.par ?? 0)")
                .frame(width: 36)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

struct ScorecardPlayerRow: View {
    @Bindable var playerScore: PlayerScore
    let viewModel: ScorecardViewModel
    let currentHoleNumber: Int?
    @Binding var scores: [UUID: Int]
    let isEditable: Bool
    let onScoreTap: ((PlayerScore, Int) -> Void)?
    
    private var playerName: String {
        playerScore.player?.name ?? "Unknown"
    }
    
    private var playerInitials: String {
        guard let name = playerScore.player?.name, !name.isEmpty else { return "?" }
        let words = name.split(separator: " ")
        return words.compactMap { $0.first }.map { String($0).uppercased() }.joined()
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Player name
            HStack(spacing: 2) {
                Text(playerInitials)
                    .frame(width: viewModel.showingStrokeInfo ? 44 : 60, alignment: .leading)
                    .font(.system(size: 10, weight: .medium))
                    .padding(.horizontal, 4)
                    .lineLimit(1)
                
                if viewModel.showingStrokeInfo {
                    Text("(\(viewModel.courseHandicap(for: playerScore.player)))")
                        .frame(width: 16)
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(.blue)
                }
            }
            
            // Front 9 scores
            ForEach(1...9, id: \.self) { holeNum in
                scoreCell(for: holeNum)
            }
            
            // Front 9 total
            Text("\(calculateNineTotal(holes: 1...9))")
                .frame(width: 36)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.blue)
            
            Divider()
                .frame(width: 1, height: 10)
                .padding(.horizontal, 4)
            
            // Back 9 scores
            ForEach(10...18, id: \.self) { holeNum in
                scoreCell(for: holeNum)
            }
            
            // Back 9 total
            Text("\(calculateNineTotal(holes: 10...18))")
                .frame(width: 36)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.blue)
            
            // Total score
            Text("\(calculateTotalScore())")
                .frame(width: 36)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.green)
        }
        .padding(.vertical, 2)
    }
    
    @ViewBuilder
    private func scoreCell(for holeNumber: Int) -> some View {
        let hole = viewModel.course?.holes.first { $0.number == holeNumber }
        let existingScore = playerScore.holeScores.first { $0.holeNumber == holeNumber }
        let currentScore = holeNumber == currentHoleNumber ? scores[playerScore.id] : nil
        let score = existingScore?.grossScore ?? currentScore
        
        ScorecardScoreCell(
            score: score,
            par: hole?.par,
            isCurrent: holeNumber == currentHoleNumber,
            hasStroke: viewModel.getsStrokeOnHole(holeNumber, for: playerScore.player),
            isEditable: isEditable && holeNumber == currentHoleNumber,
            onTap: {
                onScoreTap?(playerScore, holeNumber)
            }
        )
    }
    
    private func calculateNineTotal(holes: ClosedRange<Int>) -> String {
        var total = 0
        for hole in holes {
            if let holeScore = playerScore.holeScores.first(where: { $0.holeNumber == hole }) {
                total += holeScore.grossScore
            } else if hole == currentHoleNumber, let currentScore = scores[playerScore.id], currentScore > 0 {
                total += currentScore
            }
        }
        return total > 0 ? "\(total)" : "-"
    }
    
    private func calculateTotalScore() -> String {
        let total = playerScore.score
        return total > 0 ? "\(total)" : "-"
    }
}

struct MatchPlayDetailsSection: View {
    let viewModel: ScorecardViewModel
    let currentHoleNumber: Int?
    
    var body: some View {
        if viewModel.round.game?.gameType == .matchPlay &&
           viewModel.round.scores.count == 2 {
            VStack(spacing: 0) {
                Divider()
                    .frame(height: 1)
                    .background(Color.accentColor)
                    .padding(.vertical, 2)
                
                // Match Play Section Header
                HStack(spacing: 0) {
                    Text("MATCH PLAY")
                        .frame(width: 60, height: 14, alignment: .leading)
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.accentColor)
                        .padding(.horizontal, 4)
                    
                    Spacer()
                    
                    // Current Match Status
                    MatchPlayStatus(round: viewModel.round)
                        .padding(.horizontal, 8)
                }
                .padding(.vertical, 4)
                .background(Color.accentColor.opacity(0.1))
                
                VStack(spacing: 0) {
                    // Player 1 Row
                    MatchPlayPlayerRow(
                        playerScore: viewModel.round.scores[0],
                        opponentScore: viewModel.round.scores[1],
                        playerNumber: 1,
                        currentHoleNumber: currentHoleNumber,
                        front9Holes: viewModel.front9Holes,
                        back9Holes: viewModel.back9Holes
                    )
                    
                    Divider()
                        .frame(height: 0.5)
                        .opacity(0.5)
                    
                    // Player 2 Row
                    MatchPlayPlayerRow(
                        playerScore: viewModel.round.scores[1],
                        opponentScore: viewModel.round.scores[0],
                        playerNumber: 2,
                        currentHoleNumber: currentHoleNumber,
                        front9Holes: viewModel.front9Holes,
                        back9Holes: viewModel.back9Holes
                    )
                }
                .background(Color.accentColor.opacity(0.05))
                
                // Expandable Match Play Details
                if viewModel.showingMatchPlayDetails {
                    MatchPlayDetailedView(
                        round: viewModel.round,
                        currentHoleNumber: currentHoleNumber ?? 1
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }
}
