//
//  GameStatusView.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/12/25.
//

import SwiftUI
import SwiftData

struct GameStatusView: View {
    let round: Round
    @State private var showingDetails = false
    
    private var gameType: GameType {
        round.game?.gameType ?? .strokePlay
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(gameType.description) Status")
                        .font(.headline)
                    
                    if let game = round.game {
                        Text(game.courseName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: { showingDetails.toggle() }) {
                    Image(systemName: showingDetails ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                }
            }
            
            Divider()
            
            // Game-specific status display
            switch gameType {
            case .matchPlay:
                MatchPlayStatusView(round: round)
            case .skins:
                SkinsStatusView(round: round, showingDetails: showingDetails)
            case .nassau:
                NassauStatusView(round: round)
            case .strokePlay:
                StrokePlayStatusView(round: round)
            case .scramble:
                ScrambleStatusView(round: round)
            case .wolf:
                WolfStatusView(round: round)
            case .bestBall:
                BestBallStatusView(round: round)
            case .custom:
                StrokePlayStatusView(round: round)
            }
        }
        .padding()
    }
}

// MARK: - Match Play Status
struct MatchPlayStatusView: View {
    let round: Round
    
    private var matchStatus: (player1: Player?, player2: Player?, status: String, color: Color) {
        guard round.scores.count == 2,
              let p1 = round.scores[0].player,
              let p2 = round.scores[1].player else {
            return (nil, nil, "Invalid Match", .gray)
        }
        
        let p1Wins = calculateHolesWon(for: round.scores[0], against: round.scores[1])
        let p2Wins = calculateHolesWon(for: round.scores[1], against: round.scores[0])
        let holesPlayed = round.scores[0].holeScores.count
        let holesRemaining = 18 - holesPlayed
        
        if p1Wins > p2Wins {
            let up = p1Wins - p2Wins
            if up > holesRemaining {
                return (p1, p2, "\(p1.name) wins \(up) & \(holesRemaining)", .green)
            }
            return (p1, p2, "\(p1.name) \(up) UP", .green)
        } else if p2Wins > p1Wins {
            let up = p2Wins - p1Wins
            if up > holesRemaining {
                return (p2, p1, "\(p2.name) wins \(up) & \(holesRemaining)", .green)
            }
            return (p2, p1, "\(p2.name) \(up) UP", .green)
        }
        
        return (p1, p2, "ALL SQUARE", .orange)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Match status
            Text(matchStatus.status)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(matchStatus.color)
            
            // Hole-by-hole results
            HStack(spacing: 20) {
                // Player 1 holes won
                if let p1 = matchStatus.player1 {
                    VStack {
                        Text(p1.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(calculateHolesWon(for: round.scores[0], against: round.scores[1]))")
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                }
                
                Text("vs")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Player 2 holes won
                if let p2 = matchStatus.player2 {
                    VStack {
                        Text(p2.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(calculateHolesWon(for: round.scores[1], against: round.scores[0]))")
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                }
            }
            
            // Holes completed
            Text("\(round.scores[0].holeScores.count) of 18 holes completed")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func calculateHolesWon(for score: PlayerScore, against opponent: PlayerScore) -> Int {
        var holesWon = 0
        
        for hole in score.holeScores {
            if let opponentHole = opponent.holeScores.first(where: { $0.holeNumber == hole.holeNumber }) {
                if hole.netScore < opponentHole.netScore {
                    holesWon += 1
                }
            }
        }
        
        return holesWon
    }
}

// MARK: - Skins Status
struct SkinsStatusView: View {
    let round: Round
    let showingDetails: Bool
    
    private var skinsSummary: [(player: Player, totalWon: Double, holesWon: Int)] {
        var summary: [(player: Player, totalWon: Double, holesWon: Int)] = []
        
        for playerScore in round.scores {
            guard let player = playerScore.player else { continue }
            
            var totalWon = 0.0
            var holesWon = 0
            let betAmount = round.betAmount
            
            for holeScore in playerScore.holeScores {
                if isWinner(holeScore: holeScore, on: holeScore.holeNumber) {
                    totalWon += betAmount * Double(round.scores.count - 1)
                    holesWon += 1
                }
            }
            
            summary.append((player: player, totalWon: totalWon, holesWon: holesWon))
        }
        
        return summary.sorted(by: { $0.totalWon > $1.totalWon })
    }
    
    private var carryOverHoles: Int {
        var carryOvers = 0
        let maxHole = round.scores.flatMap { $0.holeScores }.map { $0.holeNumber }.max() ?? 0
        
        for hole in 1...maxHole {
            let scoresForHole = round.scores.compactMap { score in
                score.holeScores.first(where: { $0.holeNumber == hole })
            }
            
            guard scoresForHole.count == round.scores.count else { continue }
            
            let lowestNet = scoresForHole.map { $0.netScore }.min() ?? 0
            let winners = scoresForHole.filter { $0.netScore == lowestNet }
            
            if winners.count > 1 {
                carryOvers += 1
            }
        }
        
        return carryOvers
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Summary stats
            HStack(spacing: 20) {
                VStack {
                    Text("Total Pot")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(Int(round.betAmount * Double(round.scores.count)))")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                
                VStack {
                    Text("Per Hole")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(Int(round.betAmount))")
                        .font(.headline)
                }
                
                VStack {
                    Text("Carry Overs")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(carryOverHoles)")
                        .font(.headline)
                        .foregroundColor(.orange)
                }
            }
            
            Divider()
            
            // Player standings
            ForEach(skinsSummary, id: \.player.id) { summary in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(summary.player.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        if summary.holesWon > 0 {
                            Text("\(summary.holesWon) hole\(summary.holesWon == 1 ? "" : "s") won")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Text("$\(Int(summary.totalWon))")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(summary.totalWon > 0 ? .green : .secondary)
                }
            }
            
            // Detailed hole breakdown (optional)
            if showingDetails {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hole-by-Hole")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    HoleByHoleSkinsView(round: round)
                }
                .transition(.opacity)
            }
        }
    }
    
    private func isWinner(holeScore: HoleScore, on holeNumber: Int) -> Bool {
        let allScoresForHole = round.scores.compactMap { score in
            score.holeScores.first(where: { $0.holeNumber == holeNumber })
        }
        
        guard allScoresForHole.count == round.scores.count else { return false }
        
        let lowestNet = allScoresForHole.map { $0.netScore }.min() ?? 0
        let winners = allScoresForHole.filter { $0.netScore == lowestNet }
        
        return winners.count == 1 && winners.first?.id == holeScore.id
    }
}

// MARK: - Hole by Hole Skins View
struct HoleByHoleSkinsView: View {
    let round: Round
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(1...18, id: \.self) { hole in
                    if hasScoresForHole(hole) {
                        VStack(spacing: 4) {
                            Text("\(hole)")
                                .font(.caption2)
                                .fontWeight(.semibold)
                            
                            if let winner = getHoleWinner(hole) {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Text(String(winner.prefix(1)))
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    )
                            } else {
                                Circle()
                                    .stroke(Color.orange, lineWidth: 2)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Text("—")
                                            .font(.caption2)
                                            .foregroundColor(.orange)
                                    )
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func hasScoresForHole(_ hole: Int) -> Bool {
        round.scores.contains { score in
            score.holeScores.contains { $0.holeNumber == hole }
        }
    }
    
    private func getHoleWinner(_ holeNumber: Int) -> String? {
        let allScoresForHole = round.scores.compactMap { score in
            (score.player?.name, score.holeScores.first(where: { $0.holeNumber == holeNumber }))
        }
        
        guard allScoresForHole.count == round.scores.count else { return nil }
        
        let scores = allScoresForHole.compactMap { $0.1 }
        let lowestNet = scores.map { $0.netScore }.min() ?? 0
        let winners = allScoresForHole.filter { $0.1?.netScore == lowestNet }
        
        if winners.count == 1 {
            return winners.first?.0
        }
        
        return nil
    }
}

// MARK: - Nassau Status
struct NassauStatusView: View {
    let round: Round
    
    private var nassauStandings: [(player: Player, front9: Int, back9: Int, total: Int, money: Double)] {
        // This is simplified - real Nassau would track wins/losses for each bet
        var standings: [(player: Player, front9: Int, back9: Int, total: Int, money: Double)] = []
        
        for score in round.scores {
            guard let player = score.player else { continue }
            
            let front9 = score.holeScores.filter { $0.holeNumber <= 9 }.reduce(0) { $0 + $1.netScore }
            let back9 = score.holeScores.filter { $0.holeNumber > 9 }.reduce(0) { $0 + $1.netScore }
            let total = front9 + back9
            
            standings.append((player: player, front9: front9, back9: back9, total: total, money: 0.0))
        }
        
        return standings.sorted(by: { $0.total < $1.total })
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Three bets indicator
            HStack(spacing: 20) {
                ForEach(["Front 9", "Back 9", "Total"], id: \.self) { bet in
                    VStack {
                        Text(bet)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(Int(round.betAmount))")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }
            
            Divider()
            
            // Standings
            ForEach(nassauStandings, id: \.player.id) { standing in
                HStack {
                    Text(standing.player.name)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        if standing.front9 > 0 {
                            Text("\(standing.front9)")
                                .font(.caption)
                                .frame(width: 30)
                        } else {
                            Text("—")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 30)
                        }
                        
                        if standing.back9 > 0 {
                            Text("\(standing.back9)")
                                .font(.caption)
                                .frame(width: 30)
                        } else {
                            Text("—")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 30)
                        }
                        
                        if standing.total > 0 {
                            Text("\(standing.total)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .frame(width: 30)
                        } else {
                            Text("—")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 30)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Stroke Play Status
struct StrokePlayStatusView: View {
    let round: Round
    
    private var leaderboard: [(player: Player, gross: Int, net: Int, thru: Int)] {
        var board: [(player: Player, gross: Int, net: Int, thru: Int)] = []
        
        for score in round.scores {
            guard let player = score.player else { continue }
            
            let gross = score.score
            let net = score.netScore
            let thru = score.holeScores.count
            
            board.append((player: player, gross: gross, net: net, thru: thru))
        }
        
        return board.sorted(by: { $0.net < $1.net })
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Leader info
            if let leader = leaderboard.first, leader.net > 0 {
                VStack(spacing: 4) {
                    Text("Leader")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(leader.player.name)
                        .font(.headline)
                    Text("Net \(leader.net)")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
            }
            
            Divider()
            
            // Leaderboard
            ForEach(Array(leaderboard.enumerated()), id: \.element.player.id) { index, entry in
                HStack {
                    Text("\(index + 1)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .frame(width: 20)
                    
                    Text(entry.player.name)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    if entry.thru > 0 {
                        Text("(\(entry.thru))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("\(entry.net)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(width: 40)
                }
            }
        }
    }
}

// MARK: - Scramble Status
struct ScrambleStatusView: View {
    let round: Round
    
    private var teamScore: (gross: Int, net: Int, birdies: Int, eagles: Int) {
        // In scramble, typically track the team's best score
        var gross = 0
        var birdies = 0
        var eagles = 0
        
        // Get the best score for each hole
        let maxHole = round.scores.flatMap { $0.holeScores }.map { $0.holeNumber }.max() ?? 0
        
        for hole in 1...maxHole {
            let scoresForHole = round.scores.compactMap { score in
                score.holeScores.first(where: { $0.holeNumber == hole })
            }
            
            if let bestScore = scoresForHole.map({ $0.grossScore }).min(),
               let holeInfo = scoresForHole.first?.hole {
                gross += bestScore
                
                let diff = bestScore - holeInfo.par
                if diff == -1 { birdies += 1 }
                else if diff <= -2 { eagles += 1 }
            }
        }
        
        return (gross, gross, birdies, eagles)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Team score
            VStack(spacing: 4) {
                Text("Team Score")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if teamScore.gross > 0 {
                    Text("\(teamScore.gross)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                } else {
                    Text("—")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                }
            }
            
            // Stats
            HStack(spacing: 30) {
                VStack {
                    Image(systemName: "bird.fill")
                        .font(.title3)
                        .foregroundColor(.green)
                    Text("\(teamScore.birdies)")
                        .font(.headline)
                    Text("Birdies")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                if teamScore.eagles > 0 {
                    VStack {
                        Image(systemName: "star.fill")
                            .font(.title3)
                            .foregroundColor(.yellow)
                        Text("\(teamScore.eagles)")
                            .font(.headline)
                        Text("Eagles")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Divider()
            
            // Player contributions
            Text("Player Scores")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(round.scores) { score in
                if let player = score.player {
                    HStack {
                        Text(player.name)
                            .font(.caption)
                        
                        Spacer()
                        
                        Text("\(score.holeScores.count) holes recorded")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

// MARK: - Wolf Status (Placeholder)
struct WolfStatusView: View {
    let round: Round
    
    var body: some View {
        VStack {
            Text("Wolf game tracking coming soon")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Best Ball Status (Placeholder)
struct BestBallStatusView: View {
    let round: Round
    
    var body: some View {
        VStack {
            Text("Best Ball tracking coming soon")
                .font(.caption)
                .foregroundColor(.secondary)
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
    
    // Create test data
    let course = Course(name: "Pebble Beach", par: 72)
    
    let player1 = Player(name: "Tiger Woods", handicapIndex: 0.0)
    let player2 = Player(name: "Phil Mickelson", handicapIndex: 5.0)
    let player3 = Player(name: "Rory McIlroy", handicapIndex: 2.0)
    
    let game = Game(
        name: "Saturday Skins",
        gameType: .skins,
        courseName: course.name,
        courseRating: 72.0,
        slopeRating: 130.0,
        par: 72
    )
    
    let round = Round(
        roundNumber: 1,
        betAmount: 100.0,
        roundType: .full18
    )
    round.game = game
    
    let score1 = PlayerScore(player: player1)
    let score2 = PlayerScore(player: player2)
    let score3 = PlayerScore(player: player3)
    
    // Add some hole scores
    for i in 1...9 {
        let hs1 = HoleScore(holeNumber: i, grossScore: i == 3 ? 3 : 4)
        hs1.playerScore = score1
        score1.holeScores.append(hs1)
        
        let hs2 = HoleScore(holeNumber: i, grossScore: i == 3 ? 3 : 5)
        hs2.playerScore = score2
        score2.holeScores.append(hs2)
        
        let hs3 = HoleScore(holeNumber: i, grossScore: 4)
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
    
    try! context.save()
    
    return ScrollView {
        VStack(spacing: 20) {
            GameStatusView(round: round)
                .padding()
        }
    }
    .modelContainer(container)
}
