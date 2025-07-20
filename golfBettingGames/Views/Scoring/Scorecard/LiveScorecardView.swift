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
                        
                        // ADDED: Expandable Match Play Details
                        if showingMatchPlayDetails {
                            MatchPlayDetailedView(
                                round: round,
                                currentHoleNumber: currentHoleNumber
                            )
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    
                    if round.game?.gameType == .nassau && round.scores.count >= 2 {
                        Divider()
                            .frame(height: 1)
                            .background(Color.purple)
                            .padding(.vertical, 2)
                        
                        NassauStatusComponent(round: round)
                    }
                }
            }
            .font(.system(.body, design: .monospaced))
        }
        .cornerRadius(6)
        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}

// MARK: - Match Play Components

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
        (2, 4, 4),  // Halved
        (3, 4, 3),  // Halved
        (4, 2, 3),  // Tiger wins
        (5, 4, 5),  // Tiger wins
        (6, 2, 3),  // Halved
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
    .modelContainer(container)
}

#Preview("Nassau Live Scorecard") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
        configurations: config
    )
    
    let context = container.mainContext
    
    // Create course
    let course = Course(name: "Pebble Beach", par: 72)
    
    // Create holes with realistic pars and handicaps
    let holeData: [(par: Int, handicap: Int)] = [
        (4, 11), (5, 3), (4, 7), (4, 13), (3, 17),  // Front 9
        (5, 1), (3, 15), (4, 9), (4, 5),
        (4, 2), (4, 6), (3, 18), (4, 12), (5, 4),   // Back 9
        (4, 8), (3, 10), (5, 14), (4, 16)
    ]
    
    for (index, data) in holeData.enumerated() {
        let hole = Hole(
            number: index + 1,
            par: data.par,
            handicap: data.handicap,
            distance: 350 + (index * 25) // Varying distances
        )
        hole.course = course
        course.holes.append(hole)
    }
    
    // Create Nassau game
    let player1 = Player(name: "Jordan Spieth", handicapIndex: 4.2)
    let player2 = Player(name: "Justin Thomas", handicapIndex: 5.8)
    
    let game = Game(
        name: "Nassau Championship",
        gameType: .nassau,
        courseName: course.name,
        courseRating: 72.1,
        slopeRating: 129.0,
        par: 72
    )
    game.course = course
    
    let round = Round(
        roundNumber: 1,
        betAmount: 75.0,
        roundType: .full18
    )
    round.game = game
    
    // Create scores
    let score1 = PlayerScore(player: player1)
    let score2 = PlayerScore(player: player2)
    
    // Simulate exciting Nassau match - 14 holes played
    let holeResults = [
        (1, 4, 5),   // Jordan wins hole 1
        (2, 5, 4),   // Justin wins hole 2
        (3, 4, 4),   // Halved hole 3
        (4, 4, 5),   // Jordan wins hole 4
        (5, 3, 3),   // Halved hole 5
        (6, 4, 5),   // Jordan wins hole 6 (Jordan 2 UP front 9)
        (7, 3, 4),   // Jordan wins hole 7 (Jordan 3 UP front 9)
        (8, 4, 3),   // Justin wins hole 8 (Jordan 2 UP front 9)
        (9, 4, 4),   // Halved hole 9 (Jordan 2 UP front 9)
        (10, 5, 6),  // Jordan wins hole 10 (Jordan 1 UP back 9)
        (11, 4, 4),  // Halved hole 11 (Jordan 1 UP back 9)
        (12, 3, 4),  // Jordan wins hole 12 (Jordan 2 UP back 9)
        (13, 4, 3),  // Justin wins hole 13 (Jordan 1 UP back 9)
        (14, 5, 4),  // Justin wins hole 14 (Back 9 AS)
    ]
    
    for (hole, jordanScore, justinScore) in holeResults {
        let hs1 = HoleScore(holeNumber: hole, grossScore: jordanScore)
        hs1.playerScore = score1
        hs1.hole = course.holes.first(where: { $0.number == hole })
        score1.holeScores.append(hs1)
        
        let hs2 = HoleScore(holeNumber: hole, grossScore: justinScore)
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
        score2.id: 5
    ]
    
    struct NassauPreviewWrapper: View {
        let round: Round
        @State var scores: [UUID: Int]
        @State private var selectedView = 0
        
        var body: some View {
            NavigationView {
                VStack(spacing: 0) {
                    // Header with game info
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Nassau Championship")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            HStack(spacing: 16) {
                                Text("Pebble Beach")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text("$75 Nassau")
                                    .font(.subheadline)
                                    .foregroundColor(.purple)
                                    .fontWeight(.medium)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Hole 15")
                                .font(.headline)
                                .foregroundColor(.accentColor)
                            
                            Text("Par 4, 425 yds")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    
                    // View selector
                    Picker("View", selection: $selectedView) {
                        Text("Live Scorecard").tag(0)
                        Text("Nassau Only").tag(1)
                        Text("Summary").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    // Content based on selection
                    ScrollView {
                        switch selectedView {
                        case 0:
                            // Full Live Scorecard with Nassau
                            LiveScorecardView(
                                round: round,
                                currentHoleNumber: 15,
                                scores: $scores
                            )
                            .padding()
                            
                        case 1:
                            // Nassau Components Only
                            VStack(spacing: 16) {
                                NassauStatusComponent(round: round)
                                    .padding()
                                    .background(Color.gray.opacity(0.02))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                                    )
                                
                                // Additional Nassau insights
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Current Nassau Status")
                                        .font(.headline)
                                        .foregroundColor(.purple)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text("• Front 9:")
                                                .font(.subheadline)
                                            Spacer()
                                            Text("Jordan 2 UP (Complete)")
                                                .font(.subheadline)
                                                .foregroundColor(.blue)
                                        }
                                        
                                        HStack {
                                            Text("• Back 9:")
                                                .font(.subheadline)
                                            Spacer()
                                            Text("All Square")
                                                .font(.subheadline)
                                                .foregroundColor(.orange)
                                        }
                                        
                                        HStack {
                                            Text("• Overall:")
                                                .font(.subheadline)
                                            Spacer()
                                            Text("Jordan 2 UP")
                                                .font(.subheadline)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(8)
                                
                                // Potential press info
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Press Watch")
                                        .font(.headline)
                                        .foregroundColor(.orange)
                                    
                                    Text("If Justin falls 2 down on the back 9, a press bet may be initiated from the next hole.")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color.orange.opacity(0.05))
                                .cornerRadius(8)
                            }
                            .padding()
                            
                        case 2:
                            // Summary Card
                            VStack(spacing: 16) {
                                NassauSummaryCard(round: round)
                                
                                // Match progression
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Match Progression")
                                        .font(.headline)
                                        .foregroundColor(.purple)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Front 9 Complete: Jordan won 2 UP")
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                        
                                        Text("Back 9 Status: All Square through 5 holes")
                                            .font(.subheadline)
                                            .foregroundColor(.orange)
                                        
                                        Text("Overall Status: Jordan leads 2 UP")
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                        
                                        Text("Remaining: 4 holes to play")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(8)
                                
                                // Betting implications
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Betting Status ($75 Nassau)")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                    
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("Jordan Leading:")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Text("• Front 9: $75")
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                            Text("• Overall: Leading")
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing) {
                                            Text("Still in Play:")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Text("Back 9: $75")
                                                .font(.caption)
                                                .foregroundColor(.orange)
                                            Text("Overall: $75")
                                                .font(.caption)
                                                .foregroundColor(.orange)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.green.opacity(0.05))
                                .cornerRadius(8)
                            }
                            .padding()
                            
                        default:
                            EmptyView()
                        }
                    }
                }
                .navigationTitle("Nassau Live Scoring")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    return NassauPreviewWrapper(round: round, scores: scores)
        .modelContainer(container)
}

// Additional preview showing different Nassau scenarios
#Preview("Nassau - Press Scenario") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
        configurations: config
    )
    
    let context = container.mainContext
    
    // Create course
    let course = Course(name: "TPC Sawgrass", par: 72)
    
    // Create basic holes
    for i in 1...18 {
        let hole = Hole(
            number: i,
            par: i == 17 ? 3 : (i == 2 || i == 9 || i == 11 || i == 16 ? 5 : 4),
            handicap: i,
            distance: 400
        )
        hole.course = course
        course.holes.append(hole)
    }
    
    // Create Nassau game with press scenario
    let player1 = Player(name: "Dustin Johnson", handicapIndex: 3.1)
    let player2 = Player(name: "Brooks Koepka", handicapIndex: 4.7)
    
    let game = Game(
        name: "Press Nassau",
        gameType: .nassau,
        courseName: course.name,
        courseRating: 74.0,
        slopeRating: 132.0,
        par: 72
    )
    game.course = course
    
    let round = Round(
        roundNumber: 1,
        betAmount: 100.0,
        roundType: .full18
    )
    round.game = game
    
    // Create scores showing press scenario
    let score1 = PlayerScore(player: player1)
    let score2 = PlayerScore(player: player2)
    
    // Create scenario where player 2 is down and needs press
    let holeResults = [
        (1, 4, 5), (2, 5, 4), (3, 4, 5), (4, 4, 3), (5, 4, 4),  // Front 9
        (6, 5, 4), (7, 4, 5), (8, 4, 4), (9, 4, 4),
        (10, 4, 5), (11, 5, 4), (12, 4, 5), (13, 4, 3), (14, 4, 5), // Back 9 - DJ pulling ahead
        (15, 4, 4), (16, 5, 6)  // More holes where DJ is dominating
    ]
    
    for (hole, djScore, brooksScore) in holeResults {
        let hs1 = HoleScore(holeNumber: hole, grossScore: djScore)
        hs1.playerScore = score1
        hs1.hole = course.holes.first(where: { $0.number == hole })
        score1.holeScores.append(hs1)
        
        let hs2 = HoleScore(holeNumber: hole, grossScore: brooksScore)
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
        score2.id: 5
    ]
    
    return VStack {
        Text("Nassau with Press Scenario")
            .font(.headline)
            .padding()
        
        Text("Dustin Johnson dominating - Press bets likely")
            .font(.subheadline)
            .foregroundColor(.orange)
            .padding(.bottom)
        
        NassauStatusComponent(round: round)
            .padding()
            .background(Color.gray.opacity(0.02))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.purple.opacity(0.3), lineWidth: 1)
            )
            .padding()
        
        Spacer()
    }
    .modelContainer(container)
}
