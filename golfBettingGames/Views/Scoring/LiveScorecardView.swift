//
//  LiveScorecardView.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/11/25.
//

import SwiftUI
import SwiftData

struct LiveScorecardView: View {
    let round: Round
    let currentHoleNumber: Int
    @Binding var scores: [UUID: Int]
    @State private var showingStrokeInfo = false
    
    private var course: Course? { round.game?.course }
    
    private var holes: [Hole] {
        course?.sortedHoles ?? []
    }
    
    private var front9Holes: [Hole] {
        holes.filter { $0.number <= 9 }
    }
    
    private var back9Holes: [Hole] {
        holes.filter { $0.number > 9 }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Ultra-Compact Header
            HStack {
                Text("SCORECARD")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Toggle stroke info button
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showingStrokeInfo.toggle()
                    }
                } label: {
                    Image(systemName: showingStrokeInfo ? "info.circle.fill" : "info.circle")
                        .font(.system(size: 11))
                        .foregroundColor(.accentColor)
                }
                
                if let courseName = round.game?.courseName {
                    Text(courseName)
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color(UIColor.tertiarySystemBackground))
            
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Hole Numbers Row
                    HStack(spacing: 0) {
                        Text("HOLE") // CHANGED: Always show "HOLE" since strokes are shown on cells
                            .frame(width: 60, height: 14, alignment: .leading)
                            .font(.system(size: 8, weight: .semibold))
                            .padding(.horizontal, 4)
                        
                        // Front 9
                        ForEach(1...9, id: \.self) { hole in
                            Text("\(hole)")
                                .frame(width: 24, height: 14)
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(currentHoleNumber == hole ? .white : .primary)
                                .background(
                                    currentHoleNumber == hole ?
                                    Circle()
                                        .fill(Color.accentColor)
                                        .frame(width: 16, height: 16) : nil
                                )
                        }
                        
                        Text("OUT")
                            .frame(width: 32, height: 14)
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.blue)
                        
                        Divider()
                            .frame(width: 1, height: 10)
                            .padding(.horizontal, 2)
                        
                        // Back 9
                        ForEach(10...18, id: \.self) { hole in
                            Text("\(hole)")
                                .frame(width: 24, height: 14)
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(currentHoleNumber == hole ? .white : .primary)
                                .background(
                                    currentHoleNumber == hole ?
                                    Circle()
                                        .fill(Color.accentColor)
                                        .frame(width: 16, height: 16) : nil
                                )
                        }
                        
                        Text("IN")
                            .frame(width: 32, height: 14)
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.blue)
                        
                        Text("TOT")
                            .frame(width: 32, height: 14)
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.green)
                    }
                    .padding(.vertical, 0)
                    .background(Color(UIColor.secondarySystemBackground))
                    
                    // Par Row
                    HStack(spacing: 0) {
                        Text("PAR")
                            .frame(width: 60, height: 14, alignment: .leading)
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                        
                        // Front 9 pars
                        ForEach(front9Holes) { hole in
                            Text("\(hole.par)")
                                .frame(width: 24, height: 14)
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                        }
                        
                        // Fill empty holes
                        ForEach(front9Holes.count..<9, id: \.self) { _ in
                            Text("-")
                                .frame(width: 24, height: 14)
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                        }
                        
                        Text("\(course?.front9Par ?? 0)")
                            .frame(width: 32, height: 14)
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Divider()
                            .frame(width: 1, height: 10)
                            .padding(.horizontal, 2)
                        
                        // Back 9 pars
                        ForEach(back9Holes) { hole in
                            Text("\(hole.par)")
                                .frame(width: 24, height: 14)
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                        }
                        
                        // Fill empty holes
                        ForEach(back9Holes.count..<9, id: \.self) { _ in
                            Text("-")
                                .frame(width: 24, height: 14)
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                        }
                        
                        Text("\(course?.back9Par ?? 0)")
                            .frame(width: 32, height: 14)
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text("\(course?.par ?? 0)")
                            .frame(width: 32, height: 14)
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 0)
                    
                    Divider().frame(height: 0.5)
                    
                    // Player Rows
                    ForEach(round.scores.sorted(by: {
                        ($0.player?.name ?? "") < ($1.player?.name ?? "")
                    })) { playerScore in
                        Group {
                            // CHANGED: Removed separate stroke row, now strokes are shown on score cells
                            PlayerScorecardRow(
                                playerScore: playerScore,
                                currentHoleNumber: currentHoleNumber,
                                scores: $scores,
                                front9Holes: front9Holes,
                                back9Holes: back9Holes,
                                showingStrokeInfo: showingStrokeInfo
                            )
                            
                            Divider()
                                .frame(height: 0.5)
                                .opacity(0.5)
                        }
                    }
                }
            }
            .font(.system(.body, design: .monospaced))
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(6)
        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}

struct PlayerStrokeRow: View {
    let playerScore: PlayerScore
    let game: Game?
    let holes: [Hole]
    
    private var courseHandicap: Int {
        guard let player = playerScore.player, let game = game else { return 0 }
        return player.courseHandicap(
            courseRating: game.effectiveRating,
            slopeRating: Double(game.effectiveSlope),
            par: game.par
        )
    }
    
    private func getsStrokeOnHole(_ holeNumber: Int) -> Bool {
        guard let hole = holes.first(where: { $0.number == holeNumber }) else { return false }
        return courseHandicap >= hole.handicap
    }
    
    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("CH: \(courseHandicap)")
                    .frame(width: 60, alignment: .leading)
                    .font(.system(size: 7))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 4)
            }
            
            // Front 9 stroke indicators
            ForEach(1...9, id: \.self) { holeNum in
                ZStack {
                    if getsStrokeOnHole(holeNum) {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 12, height: 12)
                        Text("•")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.blue)
                    } else {
                        Text("")
                    }
                }
                .frame(width: 24, height: 14)
            }
            
            Text("\(min(courseHandicap, 9))")
                .frame(width: 32)
                .font(.system(size: 7))
                .foregroundColor(.blue)
            
            Divider()
                .frame(width: 1, height: 8)
                .padding(.horizontal, 2)
            
            // Back 9 stroke indicators
            ForEach(10...18, id: \.self) { holeNum in
                ZStack {
                    if getsStrokeOnHole(holeNum) {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 12, height: 12)
                        Text("•")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.blue)
                    } else {
                        Text("")
                    }
                }
                .frame(width: 24, height: 14)
            }
            
            Text("\(max(0, min(courseHandicap - 9, 9)))")
                .frame(width: 32)
                .font(.system(size: 7))
                .foregroundColor(.blue)
            
            Text("\(courseHandicap)")
                .frame(width: 32)
                .font(.system(size: 7, weight: .medium))
                .foregroundColor(.blue)
        }
        .padding(.vertical, 0)
        .background(Color.blue.opacity(0.05))
    }
}

struct CompactScoreCell: View {
    let score: Int
    let par: Int?
    let isCurrentHole: Bool
    let hasStroke: Bool // ADDED: New parameter for stroke indicator
    
    private var scoreDiff: Int {
        guard let par = par else { return 0 }
        return score - par
    }
    
    private var scoreColor: Color {
        guard let par = par else { return .primary }
        switch scoreDiff {
        case ..<(-1): return Color(red: 0.0, green: 0.6, blue: 0.0) // Eagle or better
        case -1: return .green // Birdie
        case 0: return .primary // Par
        case 1: return .orange // Bogey
        default: return .red // Double bogey or worse
        }
    }
    
//    private var scoreSymbol: String? {
//        guard let par = par else { return nil }
//        switch scoreDiff {
//        case ..<(-1): return "◎" // Eagle (double circle)
//        case -1: return "○" // Birdie (circle)
//        case 0: return nil // Par (no symbol)
//        case 1: return "□" // Bogey (square)
//        case 2: return "■" // Double bogey (filled square)
//        default: return nil
//        }
//    }
    
    var body: some View {
        ZStack {
//            if let symbol = scoreSymbol {
//                Text(symbol)
//                    .font(.system(size: 12))
//                    .foregroundColor(scoreColor.opacity(0.2))
//            }
            
            Text("\(score)")
                .frame(width: 24, height: 16)
                .font(.system(size: 8, weight: isCurrentHole ? .bold : .medium))
                .foregroundColor(scoreColor)
                .background(
                    isCurrentHole ?
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.accentColor.opacity(0.15))
                        .padding(.horizontal, 1) : nil
                )
            
            // ADDED: Small dot indicator for strokes
            if hasStroke {
                Circle()
                    .fill(Color.black)
                    .frame(width: 3, height: 3)
                    .offset(x: 8, y: -6)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
        configurations: config
    )
    
    let context = container.mainContext
    
    // Create course
    let course = Course(name: "Pebble Beach", par: 72)
    
    // Create 18 holes
    let holeData: [(par: Int, handicap: Int)] = [
        (4, 7), (5, 13), (4, 15), (4, 9), (3, 17),
        (5, 1), (3, 11), (4, 3), (4, 5),
        (4, 8), (4, 10), (3, 16), (4, 2), (5, 6),
        (4, 12), (4, 14), (3, 18), (5, 4)
    ]
    
    for (index, data) in holeData.enumerated() {
        let hole = Hole(
            number: index + 1,
            par: data.par,
            handicap: data.handicap,
            distance: 400
        )
        hole.course = course
        course.holes.append(hole)
    }
    
    // Create players and game
    let player1 = Player(name: "Tiger Woods", handicapIndex: 0.0)
    let player2 = Player(name: "Average Golfer", handicapIndex: 18.0)
    let player3 = Player(name: "High Handicapper", handicapIndex: 24.0)
    
    let game = Game(
        name: "Test Game",
        gameType: .strokePlay,
        courseName: course.name,
        courseRating: 72.0,
        slopeRating: 130.0,
        par: 72
    )
    game.course = course
    
    let round = Round(
        roundNumber: 1,
        betAmount: 50.0,
        roundType: .full18
    )
    round.game = game
    
    // Create scores
    let score1 = PlayerScore(player: player1)
    let score2 = PlayerScore(player: player2)
    let score3 = PlayerScore(player: player3)
    
    // Add some hole scores with varying performance
    for i in 1...7 {
        let hs1 = HoleScore(holeNumber: i, grossScore: i == 2 ? 3 : (i == 6 ? 6 : 4))
        hs1.playerScore = score1
        score1.holeScores.append(hs1)
        
        let hs2 = HoleScore(holeNumber: i, grossScore: i == 5 ? 2 : 5)
        hs2.playerScore = score2
        score2.holeScores.append(hs2)
        
        let hs3 = HoleScore(holeNumber: i, grossScore: i == 3 ? 8 : 6)
        hs3.playerScore = score3
        score3.holeScores.append(hs3)
    }
    
    round.scores = [score1, score2, score3]
    
    context.insert(course)
    context.insert(player1)
    context.insert(player2)
    context.insert(player3)
    context.insert(game)
    context.insert(round)
    
    @State var scores: [UUID: Int] = [
        score1.id: 4,
        score2.id: 6,
        score3.id: 7
    ]
    
    return VStack {
        Text("Ultra Compact Scorecard")
            .font(.headline)
            .padding(.top)
        
        LiveScorecardView(
            round: round,
            currentHoleNumber: 8,
            scores: $scores
        )
        .padding()
        
        Spacer()
    }
    .background(Color(UIColor.systemGroupedBackground))
    .modelContainer(container)
}
