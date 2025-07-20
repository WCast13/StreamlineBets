//
//  NassauComponets.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/17/25.
//

import SwiftUI
import SwiftData

// MARK: - Nassau Status Component with Running Status
struct NassauStatusComponent: View {
    let round: Round
    @State private var showingPresses = false
    
    private var nassauStatus: NassauGameStatus {
        NassauCalculator.calculateStatus(for: round)
    }
    
    // Get player names for display
    private var player1Name: String {
        round.scores.first?.player?.name ?? "Player 1"
    }
    
    private var player2Name: String {
        round.scores.count > 1 ? round.scores[1].player?.name ?? "Player 2" : "Player 2"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Nassau Section Header with Player Legend
            VStack(spacing: 8) {
                HStack(spacing: 0) {
                    Text("NASSAU")
                        .frame(width: 60, height: 14, alignment: .leading)
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.purple)
                        .padding(.horizontal, 4)
                    
                    Spacer()
                    
                    // Total bets indicator
                    HStack(spacing: 8) {
                        Text("\(nassauStatus.totalActiveBets) active bets")
                            .font(.system(size: 7))
                            .foregroundColor(.secondary)
                        
                        if nassauStatus.presses.count > 0 {
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showingPresses.toggle()
                                }
                            } label: {
                                HStack(spacing: 2) {
                                    Text("\(nassauStatus.presses.count)")
                                    Image(systemName: showingPresses ? "chevron.up" : "chevron.down")
                                }
                                .font(.system(size: 7))
                                .foregroundColor(.orange)
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                }
                
                // Player Legend
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                        Text(player1Name)
                            .font(.system(size: 8))
                            .foregroundColor(.blue)
                    }
                    
                    Text("vs")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        Text(player2Name)
                            .font(.system(size: 8))
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 4)
            }
            .padding(.vertical, 4)
            
            Divider()
                .frame(height: 0.5)
                .opacity(0.5)
            
            // Main Nassau Bets with Running Status
            VStack(spacing: 0) {
                NassauRunningBetRow(
                    betType: "Front 9",
                    holes: 1...9,
                    round: round,
                    player1Name: player1Name,
                    player2Name: player2Name
                )
                
                Divider()
                    .frame(height: 0.5)
                    .opacity(0.3)
                
                NassauRunningBetRow(
                    betType: "Back 9",
                    holes: 10...18,
                    round: round,
                    player1Name: player1Name,
                    player2Name: player2Name
                )
                
                Divider()
                    .frame(height: 0.5)
                    .opacity(0.3)
                
                NassauRunningBetRow(
                    betType: "Overall",
                    holes: 1...18,
                    round: round,
                    player1Name: player1Name,
                    player2Name: player2Name
                )
            }
            
            // Press Bets (if any)
            if showingPresses && !nassauStatus.presses.isEmpty {
                Divider()
                    .frame(height: 0.5)
                
                VStack(spacing: 0) {
                    ForEach(nassauStatus.presses) { press in
                        NassauRunningPressRow(
                            press: press,
                            round: round,
                            player1Name: player1Name,
                            player2Name: player2Name
                        )
                        
                        if press.id != nassauStatus.presses.last?.id {
                            Divider()
                                .frame(height: 0.5)
                                .opacity(0.3)
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - Nassau Running Bet Row
struct NassauRunningBetRow: View {
    let betType: String
    let holes: ClosedRange<Int>
    let round: Round
    let player1Name: String
    let player2Name: String
    
    private var currentHoleNumber: Int? {
        // Find the current hole being played
        guard round.scores.count >= 2 else { return nil }
        
        for hole in holes {
            let hasP1Score = round.scores[0].holeScores.contains(where: { $0.holeNumber == hole })
            let hasP2Score = round.scores[1].holeScores.contains(where: { $0.holeNumber == hole })
            
            if !hasP1Score || !hasP2Score {
                return hole
            }
        }
        return nil
    }
    
    private var finalStatus: (text: String, color: Color) {
        let status = NassauCalculator.calculateBetStatus(for: holes, in: round)
        
        switch status.leader {
        case .player1:
            if status.holesUp > 0 {
                return ("\(String(player1Name.prefix(1))) \(status.holesUp) UP", .blue)
            } else {
                return ("AS", .orange)
            }
        case .player2:
            if status.holesUp > 0 {
                return ("\(String(player2Name.prefix(1))) \(status.holesUp) UP", .red)
            } else {
                return ("AS", .orange)
            }
        case .tied:
            return ("AS", .orange)
        case .notStarted:
            return ("—", .secondary)
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Bet Type
            Text(betType)
                .frame(width: 60, alignment: .leading)
                .font(.system(size: 8, weight: .medium))
                .padding(.horizontal, 4)
            
            // Running status for each hole in range
            ForEach(holes, id: \.self) { hole in
                NassauRunningStatusCell(
                    holeNumber: hole,
                    betHoles: holes,
                    round: round,
                    player1Name: player1Name,
                    player2Name: player2Name,
                    isCurrentHole: currentHoleNumber == hole
                )
            }
            
            // Fill empty cells for back 9 alignment
            if holes.lowerBound == 10 {
                ForEach(1...9, id: \.self) { _ in
                    Text("")
                        .frame(width: 24, height: 14)
                }
            }
            
            // Final Status
            HStack(spacing: 4) {
                Text(finalStatus.text)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(finalStatus.color)
                    .frame(width: 50)
                
                let status = NassauCalculator.calculateBetStatus(for: holes, in: round)
                if status.isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.green)
                }
            }
            .frame(width: 64)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Nassau Running Status Cell
struct NassauRunningStatusCell: View {
    let holeNumber: Int
    let betHoles: ClosedRange<Int>
    let round: Round
    let player1Name: String
    let player2Name: String
    let isCurrentHole: Bool
    
    private var runningStatus: (text: String, color: Color) {
        guard round.scores.count == 2 else {
            return ("—", .secondary)
        }
        
        // Calculate running status up to this hole within the bet range
        var p1Wins = 0
        var p2Wins = 0
        
        for hole in betHoles {
            if hole > holeNumber { break }
            
            let result = NassauCalculator.getHoleResult(for: hole, in: round)
            switch result {
            case .player1Won:
                p1Wins += 1
            case .player2Won:
                p2Wins += 1
            case .halved:
                break
            case .notPlayed:
                // If this hole hasn't been played yet, show empty
                if hole == holeNumber {
                    return ("—", .secondary)
                }
            }
        }
        
        // If no scores for this hole yet
        if NassauCalculator.getHoleResult(for: holeNumber, in: round) == .notPlayed {
            return ("—", .secondary)
        }
        
        if p1Wins > p2Wins {
            return ("\(p1Wins - p2Wins)", .blue)
        } else if p2Wins > p1Wins {
            return ("\(p2Wins - p1Wins)", .red)
        } else {
            return ("AS", .orange)
        }
    }
    
    var body: some View {
        Text(runningStatus.text)
            .frame(width: 24, height: 14)
            .font(.system(size: 7, weight: isCurrentHole ? .bold : .medium))
            .foregroundColor(runningStatus.color)
            .background(
                isCurrentHole ?
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.accentColor.opacity(0.15))
                    .padding(.horizontal, 1) : nil
            )
    }
}

// MARK: - Nassau Running Press Row
struct NassauRunningPressRow: View {
    let press: NassauPress
    let round: Round
    let player1Name: String
    let player2Name: String
    
    private var currentHoleNumber: Int? {
        guard round.scores.count >= 2 else { return nil }
        
        for hole in press.startHole...press.endHole {
            let hasP1Score = round.scores[0].holeScores.contains(where: { $0.holeNumber == hole })
            let hasP2Score = round.scores[1].holeScores.contains(where: { $0.holeNumber == hole })
            
            if !hasP1Score || !hasP2Score {
                return hole
            }
        }
        return nil
    }
    
    private var finalStatus: (text: String, color: Color) {
        switch press.status.leader {
        case .player1:
            if press.status.holesUp > 0 {
                return ("\(String(player1Name.prefix(1))) \(press.status.holesUp) UP", .blue)
            } else {
                return ("AS", .orange)
            }
        case .player2:
            if press.status.holesUp > 0 {
                return ("\(String(player2Name.prefix(1))) \(press.status.holesUp) UP", .red)
            } else {
                return ("AS", .orange)
            }
        case .tied:
            return ("AS", .orange)
        case .notStarted:
            return ("—", .secondary)
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Press Type
            HStack(spacing: 2) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 7))
                    .foregroundColor(.orange)
                Text("Press \(press.startHole)")
            }
            .frame(width: 60, alignment: .leading)
            .font(.system(size: 8, weight: .medium))
            .padding(.horizontal, 4)
            .foregroundColor(.orange)
            
            // Running status for press holes
            ForEach(1...18, id: \.self) { hole in
                if hole >= press.startHole && hole <= press.endHole {
                    NassauRunningStatusCell(
                        holeNumber: hole,
                        betHoles: press.startHole...press.endHole,
                        round: round,
                        player1Name: player1Name,
                        player2Name: player2Name,
                        isCurrentHole: currentHoleNumber == hole
                    )
                } else {
                    Text("")
                        .frame(width: 24, height: 14)
                }
            }
            
            // Status
            HStack(spacing: 4) {
                Text(finalStatus.text)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(finalStatus.color)
                    .frame(width: 50)
                
                if press.status.isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.green)
                }
            }
            .frame(width: 64)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Nassau Summary Card
struct NassauSummaryCard: View {
    let round: Round
    
    private var nassauStatus: NassauGameStatus {
        NassauCalculator.calculateStatus(for: round)
    }
    
    private var player1Name: String {
        round.scores.first?.player?.name ?? "Player 1"
    }
    
    private var player2Name: String {
        round.scores.count > 1 ? round.scores[1].player?.name ?? "Player 2" : "Player 2"
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Nassau Summary")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.purple)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Front 9:")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                    Text("Back 9:")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                    Text("Overall:")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    NassauStatusDisplay(status: nassauStatus.front9Status, player1: player1Name, player2: player2Name)
                    NassauStatusDisplay(status: nassauStatus.back9Status, player1: player1Name, player2: player2Name)
                    NassauStatusDisplay(status: nassauStatus.overallStatus, player1: player1Name, player2: player2Name)
                }
            }
            
            if !nassauStatus.presses.isEmpty {
                Divider()
                    .frame(height: 0.5)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Active Presses:")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(.orange)
                    
                    ForEach(nassauStatus.presses) { press in
                        HStack {
                            Text("Holes \(press.startHole)-\(press.endHole):")
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                            Spacer()
                            NassauStatusDisplay(status: press.status, player1: player1Name, player2: player2Name)
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

struct NassauStatusDisplay: View {
    let status: NassauBetStatus
    let player1: String
    let player2: String
    
    var body: some View {
        HStack(spacing: 2) {
            switch status.leader {
            case .player1:
                Text(player1)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.blue)
                if status.holesUp > 0 {
                    Text("\(status.holesUp) UP")
                        .font(.system(size: 8))
                        .foregroundColor(.blue)
                }
            case .player2:
                Text(player2)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.red)
                if status.holesUp > 0 {
                    Text("\(status.holesUp) UP")
                        .font(.system(size: 8))
                        .foregroundColor(.red)
                }
            case .tied:
                Text("ALL SQUARE")
                    .font(.system(size: 8))
                    .foregroundColor(.orange)
            case .notStarted:
                Text("—")
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
            }
            
            if status.isComplete {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 8))
                    .foregroundColor(.green)
            }
        }
    }
}

// Keep the existing NassauCalculator and data models as they are
// They work well for the calculations
// MARK: - Nassau Calculator
struct NassauCalculator {
    static func calculateStatus(for round: Round) -> NassauGameStatus {
        guard round.scores.count == 2 else {
            return NassauGameStatus(
                front9Status: NassauBetStatus(leader: .notStarted, holesUp: 0, isComplete: false),
                back9Status: NassauBetStatus(leader: .notStarted, holesUp: 0, isComplete: false),
                overallStatus: NassauBetStatus(leader: .notStarted, holesUp: 0, isComplete: false),
                presses: [],
                totalActiveBets: 3
            )
        }
        
        let front9 = calculateBetStatus(for: 1...9, in: round)
        let back9 = calculateBetStatus(for: 10...18, in: round)
        let overall = calculateBetStatus(for: 1...18, in: round)
        let presses = findActivePresses(in: round)
        
        return NassauGameStatus(
            front9Status: front9,
            back9Status: back9,
            overallStatus: overall,
            presses: presses,
            totalActiveBets: 3 + presses.count
        )
    }
    
    static func calculateBetStatus(for holes: ClosedRange<Int>, in round: Round) -> NassauBetStatus {
        guard round.scores.count == 2 else {
            return NassauBetStatus(leader: .notStarted, holesUp: 0, isComplete: false)
        }
        
        var player1Holes = 0
        var player2Holes = 0
        var holesPlayed = 0
        
        for hole in holes {
            let result = getHoleResult(for: hole, in: round)
            if result != .notPlayed {
                holesPlayed += 1
                switch result {
                case .player1Won:
                    player1Holes += 1
                case .player2Won:
                    player2Holes += 1
                case .halved:
                    break
                case .notPlayed:
                    break
                }
            }
        }
        
        let isComplete = holesPlayed == holes.count
        
        if player1Holes > player2Holes {
            return NassauBetStatus(leader: .player1, holesUp: player1Holes - player2Holes, isComplete: isComplete)
        } else if player2Holes > player1Holes {
            return NassauBetStatus(leader: .player2, holesUp: player2Holes - player1Holes, isComplete: isComplete)
        } else {
            return NassauBetStatus(leader: .tied, holesUp: 0, isComplete: isComplete)
        }
    }
    
    static func getHoleResult(for holeNumber: Int, in round: Round) -> NassauHoleResult {
        guard round.scores.count == 2,
              let p1Score = round.scores[0].holeScores.first(where: { $0.holeNumber == holeNumber }),
              let p2Score = round.scores[1].holeScores.first(where: { $0.holeNumber == holeNumber }) else {
            return .notPlayed
        }
        
        if p1Score.netScore < p2Score.netScore {
            return .player1Won
        } else if p2Score.netScore < p1Score.netScore {
            return .player2Won
        } else {
            return .halved
        }
    }
    
    static func findActivePresses(in round: Round) -> [NassauPress] {
        // This is a simplified version - in a real app, presses would be stored in the model
        // For now, we'll simulate presses based on the game state
        var presses: [NassauPress] = []
        
        // Check if player is down by 2 or more on front 9
        let front9Status = calculateBetStatus(for: 1...9, in: round)
        if front9Status.holesUp >= 2 && !front9Status.isComplete {
            let press = NassauPress(
                id: UUID(),
                startHole: 7,
                endHole: 9,
                status: calculateBetStatus(for: 7...9, in: round)
            )
            presses.append(press)
        }
        
        // Check if player is down by 2 or more on back 9
        let back9Status = calculateBetStatus(for: 10...18, in: round)
        if back9Status.holesUp >= 2 && !back9Status.isComplete {
            let press = NassauPress(
                id: UUID(),
                startHole: 16,
                endHole: 18,
                status: calculateBetStatus(for: 16...18, in: round)
            )
            presses.append(press)
        }
        
        return presses
    }
}

// MARK: - Nassau Data Models
struct NassauGameStatus {
    let front9Status: NassauBetStatus
    let back9Status: NassauBetStatus
    let overallStatus: NassauBetStatus
    let presses: [NassauPress]
    let totalActiveBets: Int
}

struct NassauBetStatus {
    enum Leader {
        case player1
        case player2
        case tied
        case notStarted
    }
    
    let leader: Leader
    let holesUp: Int
    let isComplete: Bool
}

struct NassauPress: Identifiable {
    let id: UUID
    let startHole: Int
    let endHole: Int
    let status: NassauBetStatus
}

enum NassauHoleResult {
    case player1Won
    case player2Won
    case halved
    case notPlayed
}

// MARK: - Nassau Scorecard Preview
#Preview("Nassau Scorecard - Running Status") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
        configurations: config
    )
    
    let context = container.mainContext
    
    // Create course
    let course = Course(name: "Pinehurst No. 2", par: 72)
    
    // Create holes with realistic data
    let holeData: [(par: Int, handicap: Int)] = [
        (4, 11), (4, 3), (4, 9), (5, 1), (4, 15),  // Front 9
        (4, 7), (4, 5), (4, 17), (3, 13),
        (5, 6), (4, 2), (4, 10), (4, 18), (3, 16), // Back 9
        (4, 8), (3, 14), (4, 4), (4, 12)
    ]
    
    for (index, data) in holeData.enumerated() {
        let hole = Hole(
            number: index + 1,
            par: data.par,
            handicap: data.handicap,
            distance: 350 + (index * 20) // Varying distances
        )
        hole.course = course
        course.holes.append(hole)
    }
    
    // Create Nassau game with famous players
    let player1 = Player(name: "Jack Nicklaus", handicapIndex: 5.2)
    let player2 = Player(name: "Arnold Palmer", handicapIndex: 7.8)
    
    let game = Game(
        name: "Nassau Challenge",
        gameType: .nassau,
        courseName: course.name,
        courseRating: 72.0,
        slopeRating: 131.0,
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
    
    // Simulate an exciting Nassau match with 15 holes played
    let holeResults = [
        (1, 4, 5),   // Jack wins hole 1 (1 UP)
        (2, 4, 4),   // Halved hole 2 (1 UP)
        (3, 5, 4),   // Arnold wins hole 3 (AS)
        (4, 4, 5),   // Jack wins hole 4 (1 UP)
        (5, 4, 4),   // Halved hole 5 (1 UP)
        (6, 3, 4),   // Jack wins hole 6 (2 UP)
        (7, 5, 4),   // Arnold wins hole 7 (1 UP)
        (8, 4, 3),   // Arnold wins hole 8 (AS)
        (9, 3, 3),   // Halved hole 9 (AS) - Front 9 complete
        (10, 5, 6),  // Jack wins hole 10 (1 UP on back)
        (11, 4, 4),  // Halved hole 11 (1 UP on back)
        (12, 4, 5),  // Jack wins hole 12 (2 UP on back)
        (13, 3, 4),  // Jack wins hole 13 (3 UP on back - press would be initiated)
        (14, 4, 3),  // Arnold wins hole 14 (2 UP on back)
        (15, 4, 4),  // Halved hole 15 (2 UP on back)
    ]
    
    for (hole, jackScore, arnoldScore) in holeResults {
        let hs1 = HoleScore(holeNumber: hole, grossScore: jackScore)
        hs1.playerScore = score1
        hs1.hole = course.holes.first(where: { $0.number == hole })
        score1.holeScores.append(hs1)
        
        let hs2 = HoleScore(holeNumber: hole, grossScore: arnoldScore)
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
    
    struct PreviewWrapper: View {
        let round: Round
        @State private var showingNassauSection = true
        @State private var showingSummaryCard = false
        
        var body: some View {
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Nassau Challenge")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text("Pinehurst No. 2")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("$50 Nassau")
                                    .font(.headline)
                                    .foregroundColor(.purple)
                                
                                Text("Hole 16")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                        
                        // Toggle between views
                        Picker("View", selection: $showingSummaryCard) {
                            Text("Scorecard").tag(false)
                            Text("Summary").tag(true)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        
                        if showingSummaryCard {
                            // Summary Card View
                            VStack(spacing: 16) {
                                NassauSummaryCard(round: round)
                                
                                // Additional info
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Match Status")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.purple)
                                    
                                    HStack {
                                        Text("• Front 9: All Square")
                                            .font(.system(size: 10))
                                            .foregroundColor(.orange)
                                        
                                        Spacer()
                                        
                                        Text("• Back 9: Jack 2 UP")
                                            .font(.system(size: 10))
                                            .foregroundColor(.blue)
                                    }
                                    
                                    HStack {
                                        Text("• Overall: Jack 2 UP")
                                            .font(.system(size: 10))
                                            .foregroundColor(.blue)
                                        
                                        Spacer()
                                        
                                        Text("• 3 holes remaining")
                                            .font(.system(size: 10))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(8)
                            }
                            .padding()
                            
                        } else {
                            // Full Scorecard View
                            VStack(spacing: 0) {
                                // Hole numbers header
                                HStack(spacing: 0) {
                                    Text("HOLE")
                                        .frame(width: 60, height: 20, alignment: .leading)
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 4)
                                    
                                    // Front 9 hole numbers
                                    ForEach(1...9, id: \.self) { hole in
                                        Text("\(hole)")
                                            .frame(width: 24, height: 20)
                                            .font(.system(size: 8, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Text("OUT")
                                        .frame(width: 36, height: 20)
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.secondary)
                                    
                                    Divider()
                                        .frame(width: 1, height: 12)
                                        .padding(.horizontal, 2)
                                    
                                    // Back 9 hole numbers
                                    ForEach(10...18, id: \.self) { hole in
                                        Text("\(hole)")
                                            .frame(width: 24, height: 20)
                                            .font(.system(size: 8, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Text("IN")
                                        .frame(width: 36, height: 20)
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.secondary)
                                    
                                    Text("TOT")
                                        .frame(width: 64, height: 20)
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.1))
                                
                                Divider()
                                
                                // Nassau Status View
                                NassauStatusComponent(round: round)
                                    .padding()
                                    .background(Color.gray.opacity(0.02))
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                            )
                            .padding()
                        }
                        
                        // Legend
                        VStack(alignment: .leading, spacing: 8) {
                            Text("How to Read Nassau Status")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.purple)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("1, 2, 3")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.blue)
                                    Text("= Player leading by that many holes")
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack {
                                    Text("AS")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.orange)
                                    Text("= All Square (tied)")
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack {
                                    Text("—")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.secondary)
                                    Text("= Hole not played yet")
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                }
                .navigationTitle("Nassau Preview")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    return PreviewWrapper(round: round)
        .modelContainer(container)
}

// Additional preview showing different game states
#Preview("Nassau - Close Match") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
        configurations: config
    )
    
    let context = container.mainContext
    
    // Create a simple course for this preview
    let course = Course(name: "Augusta National", par: 72)
    
    // Create basic holes
    for i in 1...18 {
        let hole = Hole(
            number: i,
            par: i <= 4 || i >= 15 ? 5 : (i == 6 || i == 12 || i == 16 ? 3 : 4),
            handicap: i,
            distance: 400
        )
        hole.course = course
        course.holes.append(hole)
    }
    
    // Create players
    let player1 = Player(name: "Tiger Woods", handicapIndex: 2.1)
    let player2 = Player(name: "Rory McIlroy", handicapIndex: 3.4)
    
    let game = Game(
        name: "Masters Nassau",
        gameType: .nassau,
        courseName: course.name,
        courseRating: 72.0,
        slopeRating: 131.0,
        par: 72
    )
    game.course = course
    
    let round = Round(
        roundNumber: 1,
        betAmount: 100.0,
        roundType: .full18
    )
    round.game = game
    
    // Create scores for a very close match
    let score1 = PlayerScore(player: player1)
    let score2 = PlayerScore(player: player2)
    
    // Close match through 18 holes
    let holeResults = [
        (1, 4, 4), (2, 4, 3), (3, 5, 5), (4, 4, 4), (5, 4, 5),  // Front 9
        (6, 3, 3), (7, 4, 4), (8, 4, 3), (9, 3, 4),
        (10, 5, 5), (11, 4, 4), (12, 3, 3), (13, 4, 5), (14, 4, 4), // Back 9
        (15, 5, 4), (16, 3, 3), (17, 4, 4), (18, 4, 3)
    ]
    
    for (hole, tigerScore, roryScore) in holeResults {
        let hs1 = HoleScore(holeNumber: hole, grossScore: tigerScore)
        hs1.playerScore = score1
        hs1.hole = course.holes.first(where: { $0.number == hole })
        score1.holeScores.append(hs1)
        
        let hs2 = HoleScore(holeNumber: hole, grossScore: roryScore)
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
    
    return VStack {
        Text("Complete 18-Hole Nassau")
            .font(.headline)
            .padding()
        
        NassauStatusComponent(round: round)
            .padding()
            .background(Color.gray.opacity(0.02))
            .cornerRadius(8)
            .padding()
        
        NassauSummaryCard(round: round)
            .padding()
        
        Spacer()
    }
    .modelContainer(container)
}
