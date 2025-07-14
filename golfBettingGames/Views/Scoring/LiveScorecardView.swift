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
    @State private var showingMatchPlayDetails = false
    
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
                
                if round.game?.gameType == .matchPlay {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showingMatchPlayDetails.toggle()
                        }
                    } label: {
                        Image(systemName: showingMatchPlayDetails ? "flag.2.crossed.fill" : "flag.2.crossed")
                            .font(.system(size: 11))
                            .foregroundColor(.accentColor)
                    }
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
                        Text("HOLE")
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
                    
                    // ADDED: Match Play Details Section
                    if round.game?.gameType == .matchPlay && round.scores.count == 2 {
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
                            MatchPlayStatus(round: round)
                                .padding(.horizontal, 8)
                        }
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.1))
                        
                        VStack(spacing: 0) {
                            // Player 1 Row
                            MatchPlayPlayerRow(
                                playerScore: round.scores[0],
                                opponentScore: round.scores[1],
                                playerNumber: 1,
                                currentHoleNumber: currentHoleNumber,
                                front9Holes: front9Holes,
                                back9Holes: back9Holes
                            )
                            
                            Divider()
                                .frame(height: 0.5)
                                .opacity(0.5)
                            
                            // Player 2 Row
                            MatchPlayPlayerRow(
                                playerScore: round.scores[1],
                                opponentScore: round.scores[0],
                                playerNumber: 2,
                                currentHoleNumber: currentHoleNumber,
                                front9Holes: front9Holes,
                                back9Holes: back9Holes
                            )
                        }
                        .background(Color.accentColor.opacity(0.05))
                        
                        // ADDED: Expandable Match Play Details
                        if showingMatchPlayDetails {
                            MatchPlayDetailedView(
                                round: round,
                                currentHoleNumber: currentHoleNumber
                            )
                            .transition(.opacity.combined(with: .move(edge: .top)))
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

// MARK: - Match Play Components

struct MatchPlayPlayerRow: View {
    let playerScore: PlayerScore
    let opponentScore: PlayerScore
    let playerNumber: Int
    let currentHoleNumber: Int
    let front9Holes: [Hole]
    let back9Holes: [Hole]
    
    private var playerName: String {
        if let name = playerScore.player?.name {
            return String(name.prefix(8))
        }
        return "Player \(playerNumber)"
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Text(playerName)
                .frame(width: 60, alignment: .leading)
                .font(.system(size: 8, weight: .medium))
                .padding(.horizontal, 4)
                .lineLimit(1)
            
            // Front 9 match play results
            ForEach(1...9, id: \.self) { holeNum in
                MatchPlayCellResult(
                    playerScore: playerScore,
                    opponentScore: opponentScore,
                    holeNumber: holeNum,
                    isCurrentHole: currentHoleNumber == holeNum
                )
            }
            
            Text("")
                .frame(width: 32)
            
            Divider()
                .frame(width: 1, height: 10)
                .padding(.horizontal, 2)
            
            // Back 9 match play results
            ForEach(10...18, id: \.self) { holeNum in
                MatchPlayCellResult(
                    playerScore: playerScore,
                    opponentScore: opponentScore,
                    holeNumber: holeNum,
                    isCurrentHole: currentHoleNumber == holeNum
                )
            }
            
            Text("")
                .frame(width: 32)
            
            // Total match status
            MatchPlayTotalStatus(
                playerScore: playerScore,
                opponentScore: opponentScore
            )
            .frame(width: 32)
        }
        .padding(.vertical, 2)
    }
}

struct MatchPlayCellResult: View {
    let playerScore: PlayerScore
    let opponentScore: PlayerScore
    let holeNumber: Int
    let isCurrentHole: Bool
    
    private var result: (text: String, color: Color) {
        // Calculate match status up to this hole
        var playerWins = 0
        var opponentWins = 0
        
        // Count wins/losses for all holes up to and including this hole
        for holeNum in 1...holeNumber {
            if let playerHole = playerScore.holeScores.first(where: { $0.holeNumber == holeNum }),
               let opponentHole = opponentScore.holeScores.first(where: { $0.holeNumber == holeNum }) {
                if playerHole.netScore < opponentHole.netScore {
                    playerWins += 1
                } else if playerHole.netScore > opponentHole.netScore {
                    opponentWins += 1
                }
            } else {
                // If we haven't played this hole yet, return empty
                return ("-", .secondary)
            }
        }
        
        // Return the match status after this hole
        if playerWins > opponentWins {
            return ("\(playerWins - opponentWins)", .green)
        } else if opponentWins > playerWins {
            return ("-\(opponentWins - playerWins)", .red)
        } else {
            return ("AS", .orange)
        }
    }
    
    var body: some View {
        Text(result.text)
            .frame(width: 24, height: 16)
            .font(.system(size: 8, weight: isCurrentHole ? .bold : .medium))
            .foregroundColor(result.color)
            .background(
                isCurrentHole ?
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.accentColor.opacity(0.15))
                    .padding(.horizontal, 1) : nil
            )
    }
}

struct MatchPlayTotalStatus: View {
    let playerScore: PlayerScore
    let opponentScore: PlayerScore
    
    private var totalStatus: (text: String, color: Color) {
        var wins = 0
        var losses = 0
        
        for hole in playerScore.holeScores {
            if let opponentHole = opponentScore.holeScores.first(where: { $0.holeNumber == hole.holeNumber }) {
                if hole.netScore < opponentHole.netScore {
                    wins += 1
                } else if hole.netScore > opponentHole.netScore {
                    losses += 1
                }
            }
        }
        
        if wins > losses {
            return ("+\(wins - losses)", .green)
        } else if losses > wins {
            return ("-\(losses - wins)", .red)
        } else {
            return ("AS", .orange)
        }
    }
    
    var body: some View {
        Text(totalStatus.text)
            .font(.system(size: 8, weight: .bold))
            .foregroundColor(totalStatus.color)
    }
}

struct MatchPlayLegend: View {
    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 4) {
                Text("2")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.green)
                    .frame(width: 16)
                Text("= 2 up")
                    .font(.system(size: 7))
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 4) {
                Text("-1")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.red)
                    .frame(width: 16)
                Text("= 1 down")
                    .font(.system(size: 7))
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 4) {
                Text("AS")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.orange)
                    .frame(width: 16)
                Text("= All Square")
                    .font(.system(size: 7))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(4)
    }
}

// MARK: - Preview
#Preview("Match Play Scorecard") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
        configurations: config
    )
    
    let context = container.mainContext
    
    // Create course
    let course = Course(name: "Augusta National", par: 72)
    
    // Create holes with handicaps
    let holeData: [(par: Int, handicap: Int)] = [
        (4, 10), (5, 4), (4, 2), (3, 16), (4, 14),
        (3, 8), (4, 18), (5, 6), (4, 12),
        (4, 5), (4, 1), (3, 9), (5, 13), (4, 17),
        (5, 7), (3, 11), (4, 15), (4, 3)
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
    
    // Create match play game
    let player1 = Player(name: "Tiger Woods", handicapIndex: 2.5)
    let player2 = Player(name: "Phil Mickelson", handicapIndex: 5.3)
    
    let game = Game(
        name: "Match Play Championship",
        gameType: .matchPlay,
        courseName: course.name,
        courseRating: 72.0,
        slopeRating: 135.0,
        par: 72
    )
    game.course = course
    
    let round = Round(
        roundNumber: 1,
        betAmount: 100.0,
        roundType: .full18
    )
    round.game = game
    
    // Create scores
    let score1 = PlayerScore(player: player1)
    let score2 = PlayerScore(player: player2)
    
    // Simulate 10 holes played with match play results
    let holeResults = [
        (1, 4, 5),  // Tiger wins
        (2, 5, 5),  // Halved
        (3, 4, 4),  // Halved
        (4, 2, 3),  // Tiger wins
        (5, 4, 5),  // Tiger wins
        (6, 3, 3),  // Halved
        (7, 5, 4),  // Phil wins
        (8, 4, 6),  // Tiger wins
        (9, 4, 4),  // Halved
        (10, 5, 4), // Phil wins
    ]
    
    for (hole, tigerScore, philScore) in holeResults {
        let hs1 = HoleScore(holeNumber: hole, grossScore: tigerScore)
        hs1.playerScore = score1
        hs1.hole = course.holes.first(where: { $0.number == hole })
        score1.holeScores.append(hs1)
        
        let hs2 = HoleScore(holeNumber: hole, grossScore: philScore)
        hs2.playerScore = score2
        hs2.hole = course.holes.first(where: { $0.number == hole })
        score2.holeScores.append(hs2)
    }
    
    round.scores = [score1, score2]
    
    context.insert(course)
    context.insert(player1)
    context.insert(player2)
    context.insert(game)
    context.insert(round)
    
    @State var scores: [UUID: Int] = [
        score1.id: 4,
        score2.id: 3
    ]
    
    return VStack {
        Text("Match Play Scorecard")
            .font(.headline)
            .padding(.top)
        
        LiveScorecardView(
            round: round,
            currentHoleNumber: 11,
            scores: $scores
        )
        .padding()
        
        Spacer()
    }
    .background(Color(UIColor.systemGroupedBackground))
    .modelContainer(container)
}
