//
//  NassauComponets.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/17/25.
//

import SwiftUI
import SwiftData

// MARK: - Nassau Status Component
struct NassauStatusComponet: View {
    let round: Round
    @State private var showingPresses = false
    
    private var nassauStatus: NassauGameStatus {
        NassauCalculator.calculateStatus(for: round)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Nassau Section Header
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
            .padding(.vertical, 4)
            
            Divider()
                .frame(height: 0.5)
                .opacity(0.5)
            
            // Main Nassau Bets
            VStack(spacing: 0) {
                NassauBetRow(
                    betType: "Front 9",
                    status: nassauStatus.front9Status,
                    holes: 1...9,
                    round: round
                )
                
                Divider()
                    .frame(height: 0.5)
                    .opacity(0.3)
                
                NassauBetRow(
                    betType: "Back 9",
                    status: nassauStatus.back9Status,
                    holes: 10...18,
                    round: round
                )
                
                Divider()
                    .frame(height: 0.5)
                    .opacity(0.3)
                
                NassauBetRow(
                    betType: "Overall",
                    status: nassauStatus.overallStatus,
                    holes: 1...18,
                    round: round
                )
            }
            
            // Press Bets (if any)
            if showingPresses && !nassauStatus.presses.isEmpty {
                Divider()
                    .frame(height: 0.5)
                
                VStack(spacing: 0) {
                    ForEach(nassauStatus.presses) { press in
                        NassauPressRow(press: press, round: round)
                        
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

// MARK: - Nassau Bet Row
struct NassauBetRow: View {
    let betType: String
    let status: NassauBetStatus
    let holes: ClosedRange<Int>
    let round: Round
    
    private var statusColor: Color {
        switch status.leader {
        case .player1: return .blue
        case .player2: return .red
        case .tied: return .orange
        case .notStarted: return .secondary
        }
    }
    
    private var statusText: String {
        switch status.leader {
        case .player1:
            return status.holesUp > 0 ? "\(status.holesUp) UP" : "AS"
        case .player2:
            return status.holesUp > 0 ? "\(status.holesUp) DOWN" : "AS"
        case .tied:
            return "AS"
        case .notStarted:
            return "—"
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Bet Type
            Text(betType)
                .frame(width: 60, alignment: .leading)
                .font(.system(size: 8, weight: .medium))
                .padding(.horizontal, 4)
            
            // Hole-by-hole status
            ForEach(holes, id: \.self) { hole in
                NassauHoleCell(
                    holeNumber: hole,
                    round: round
                )
            }
            
            // Fill empty cells for back 9
            if holes.lowerBound == 10 {
                ForEach(1...9, id: \.self) { _ in
                    Text("")
                        .frame(width: 24, height: 14)
                }
            }
            
            // Total/Status
            HStack(spacing: 4) {
                Text(statusText)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(statusColor)
                    .frame(width: 32)
                
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

// MARK: - Nassau Press Row
struct NassauPressRow: View {
    let press: NassauPress
    let round: Round
    
    private var statusColor: Color {
        switch press.status.leader {
        case .player1: return .blue
        case .player2: return .red
        case .tied: return .orange
        case .notStarted: return .secondary
        }
    }
    
    private var statusText: String {
        switch press.status.leader {
        case .player1:
            return press.status.holesUp > 0 ? "\(press.status.holesUp) UP" : "AS"
        case .player2:
            return press.status.holesUp > 0 ? "\(press.status.holesUp) DOWN" : "AS"
        case .tied:
            return "AS"
        case .notStarted:
            return "—"
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
            
            // Hole indicators
            ForEach(1...18, id: \.self) { hole in
                if hole >= press.startHole && hole <= press.endHole {
                    NassauHoleCell(
                        holeNumber: hole,
                        round: round,
                        isPressHole: true
                    )
                } else {
                    Text("")
                        .frame(width: 24, height: 14)
                }
            }
            
            // Status
            HStack(spacing: 4) {
                Text(statusText)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(statusColor)
                    .frame(width: 32)
                
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

// MARK: - Nassau Hole Cell
struct NassauHoleCell: View {
    let holeNumber: Int
    let round: Round
    var isPressHole: Bool = false
    
    private var holeResult: NassauHoleResult {
        NassauCalculator.getHoleResult(for: holeNumber, in: round)
    }
    
    private var resultColor: Color {
        switch holeResult {
        case .player1Won: return .blue
        case .player2Won: return .red
        case .halved: return .orange
        case .notPlayed: return .secondary
        }
    }
    
    private var resultSymbol: String {
        switch holeResult {
        case .player1Won: return "●"
        case .player2Won: return "●"
        case .halved: return "◐"
        case .notPlayed: return "○"
        }
    }
    
    var body: some View {
        Text(resultSymbol)
            .frame(width: 24, height: 14)
            .font(.system(size: isPressHole ? 10 : 8))
            .foregroundColor(resultColor)
            .background(
                isPressHole ?
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.orange.opacity(0.1))
                    .padding(.horizontal, 2) : nil
            )
    }
}

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
#Preview("Nassau Scorecard") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
        configurations: config
    )
    
    let context = container.mainContext
    
    // Create course
    let course = Course(name: "Pinehurst No. 2", par: 72)
    
    // Create holes
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
            distance: 400
        )
        hole.course = course
        course.holes.append(hole)
    }
    
    // Create Nassau game
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
    
    // Simulate 13 holes played
    let holeResults = [
        (1, 4, 5),   // Jack wins
        (2, 4, 4),   // Halved
        (3, 5, 4),   // Arnold wins
        (4, 4, 5),   // Jack wins
        (5, 4, 4),   // Halved
        (6, 3, 4),   // Jack wins (now 2 up)
        (7, 5, 4),   // Arnold wins
        (8, 4, 3),   // Arnold wins (back to AS)
        (9, 3, 3),   // Halved - Front 9 complete
        (10, 5, 6),  // Jack wins
        (11, 4, 4),  // Halved
        (12, 4, 5),  // Jack wins (now 2 up on back)
        (13, 3, 4),  // Jack wins (3 up on back - press initiated)
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
    
    @State var scores: [UUID: Int] = [
        score1.id: 4,
        score2.id: 5
    ]
    
    struct PreviewWrapper: View {
        let round: Round
        @State var scores: [UUID: Int]
        @State private var showingNassauSection = true
        
        var body: some View {
            VStack {
                Text("Nassau Scorecard")
                    .font(.headline)
                    .padding(.top)
                
                // Just show the Nassau section for clarity
                if showingNassauSection {
                    VStack(spacing: 0) {
                        // Simplified scorecard header
                        HStack {
                            Text("NASSAU SCORING")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.purple)
                            
                            Spacer()
                            
                            Text(round.game?.courseName ?? "")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        
                        Divider()
                        
                        // Nassau Status View
                        NassauStatusComponet(round: round)
                            .padding()
                            .background(Color.gray.opacity(0.02))
                            .cornerRadius(8)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                    )
                    .padding()
                }
                
                Spacer()
            }
        }
    }
    
    return PreviewWrapper(round: round, scores: scores)
        .modelContainer(container)
}

