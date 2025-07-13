//
//  LiveScoreCard.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/7/25.
//

import SwiftUI
import SwiftData

struct LiveScoreCard: View {
    @Bindable var playerScore: PlayerScore
    @Binding var score: Int
    let holeInfo: Hole?
    let courseHandicap: Int
    let gameType: GameType
    let allScores: [PlayerScore] // ADDED: To compare with other players
    
    private var strokesOnHole: Int {
        guard let hole = holeInfo else { return 0 }
        return courseHandicap >= hole.handicap ? 1 : 0
    }
    
    // ADDED: Match Play Status
    private var matchPlayStatus: (status: String, color: Color)? {
        guard gameType == .matchPlay,
              allScores.count == 2,
              let opponent = allScores.first(where: { $0.id != playerScore.id }) else { return nil }
        
        let myHolesWon = calculateHolesWon(for: playerScore)
        let opponentHolesWon = calculateHolesWon(for: opponent)
        
        if myHolesWon > opponentHolesWon {
            return ("\(myHolesWon - opponentHolesWon) UP", .green)
        } else if myHolesWon < opponentHolesWon {
            return ("\(opponentHolesWon - myHolesWon) DOWN", .red)
        } else {
            return ("ALL SQUARE", .orange)
        }
    }
    
    // ADDED: Skins Status for Current Hole
    private var currentHoleSkinStatus: (winner: String?, amount: Double)? {
        guard gameType == .skins,
              let holeNum = holeInfo?.number else { return nil }
        
        // Check if this hole has been completed by all players
        let allScoresForHole = allScores.compactMap { score in
            score.holeScores.first(where: { $0.holeNumber == holeNum })
        }
        
        guard allScoresForHole.count == allScores.count else { return nil }
        
        // Find lowest net score
        let lowestNet = allScoresForHole.map { $0.netScore }.min() ?? 0
        let winners = allScoresForHole.filter { $0.netScore == lowestNet }
        
        if winners.count == 1,
           let winner = winners.first,
           let winnerPlayer = allScores.first(where: { $0.holeScores.contains(winner) })?.player {
            let skinAmount = playerScore.round?.betAmount ?? 0
            return (winnerPlayer.name, skinAmount * Double(allScores.count - 1))
        }
        
        return ("Carry Over", 0)
    }
    
    // ADDED: Scramble Best Score
    private var scrambleBestScore: Int? {
        guard gameType == .scramble else { return nil }
        
        let currentScores = allScores.compactMap { playerScore in
            if playerScore.id == self.playerScore.id {
                return score > 0 ? score : nil
            } else {
                return playerScore.holeScores.first(where: { $0.holeNumber == holeInfo?.number ?? 0 })?.grossScore
            }
        }
        
        return currentScores.min()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Player Header with Game-Specific Info
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(playerScore.player?.name ?? "Unknown")
                        .font(.headline)
                    
                    // ADDED: Game-specific status
                    if let matchStatus = matchPlayStatus {
                        Text(matchStatus.status)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(matchStatus.color)
                    }
                    
                    if strokesOnHole > 0 {
                        Label("Gets \(strokesOnHole) stroke(s)", systemImage: "circle.fill")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                // Running total or game-specific info
                VStack(alignment: .trailing, spacing: 2) {
                    if gameType == .skins {
                        Text("$\(Int(calculateSkinsWon()))")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(calculateSkinsWon() > 0 ? .green : .secondary)
                    } else if playerScore.score > 0 {
                        Text("Total: \(playerScore.score)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Divider()
            
            // Score Entry Section
            VStack(spacing: 8) {
                // ADDED: Scramble best score indicator
                if let bestScore = scrambleBestScore, bestScore < score {
                    HStack {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        Text("Best score: \(bestScore)")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                HStack {
                    Button(action: {
                        if score > 1 {
                            score -= 1
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundColor(score > 1 ? .accentColor : .gray)
                    }
                    .disabled(score <= 1)
                    
                    Text("\(score)")
                        .font(.title)
                        .fontWeight(.bold)
                        .frame(minWidth: 60)
                        .foregroundColor(.primary)
                    
                    Button(action: {
                        if score < 12 {
                            score += 1
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(score < 12 ? .accentColor : .gray)
                    }
                    .disabled(score >= 12)
                    
                    Spacer()
                    
                    if let hole = holeInfo {
                        ScoreToPar(score: score, par: hole.par)
                    }
                }
                
                // ADDED: Game-specific indicators
                if gameType == .skins, let skinStatus = currentHoleSkinStatus {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        if let winner = skinStatus.winner {
                            Text("\(winner): $\(Int(skinStatus.amount))")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else {
                            Text(skinStatus.winner ?? "")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(strokeBorderColor(), lineWidth: 2)
        )
    }
    
    // ADDED: Helper function to calculate holes won for match play
    private func calculateHolesWon(for score: PlayerScore) -> Int {
        var holesWon = 0
        let myHoles = score.holeScores.sorted { $0.holeNumber < $1.holeNumber }
        
        for hole in myHoles {
            if let opponentHole = allScores
                .first(where: { $0.id != score.id })?
                .holeScores
                .first(where: { $0.holeNumber == hole.holeNumber }) {
                
                if hole.netScore < opponentHole.netScore {
                    holesWon += 1
                }
            }
        }
        
        return holesWon
    }
    
    // ADDED: Calculate total skins won
    private func calculateSkinsWon() -> Double {
        var totalWon = 0.0
        let betAmount = playerScore.round?.betAmount ?? 0
        
        for holeScore in playerScore.holeScores {
            let holeNum = holeScore.holeNumber
            let allScoresForHole = allScores.compactMap { score in
                score.holeScores.first(where: { $0.holeNumber == holeNum })
            }
            
            guard allScoresForHole.count == allScores.count else { continue }
            
            let lowestNet = allScoresForHole.map { $0.netScore }.min() ?? 0
            let winners = allScoresForHole.filter { $0.netScore == lowestNet }
            
            if winners.count == 1 && winners.first?.playerScore?.id == playerScore.id {
                totalWon += betAmount * Double(allScores.count - 1)
            }
        }
        
        return totalWon
    }
    
    // ADDED: Dynamic border color based on game state
    private func strokeBorderColor() -> Color {
        switch gameType {
        case .matchPlay:
            if let status = matchPlayStatus {
                return status.color.opacity(0.3)
            }
        case .skins:
            return calculateSkinsWon() > 0 ? Color.green.opacity(0.3) : Color.clear
        case .scramble:
            if let bestScore = scrambleBestScore, score == bestScore {
                return Color.yellow.opacity(0.3)
            }
        default:
            break
        }
        return Color.clear
    }
}

// Helper view to show score relative to par
struct ScoreToPar: View {
    let score: Int
    let par: Int
    
    private var difference: Int { score - par }
    
    private var label: String {
        switch difference {
        case ..<(-2): return "Eagle or better"
        case -2: return "Eagle"
        case -1: return "Birdie"
        case 0: return "Par"
        case 1: return "Bogey"
        case 2: return "Double Bogey"
        case 3: return "Triple Bogey"
        default: return "+\(difference)"
        }
    }
    
    private var color: Color {
        switch difference {
        case ..<0: return .green
        case 0: return .primary
        case 1: return .orange
        default: return .red
        }
    }
    
    var body: some View {
        Text(label)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .cornerRadius(8)
    }
}

// MARK: - Preview
#Preview("Match Play") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
        configurations: config
    )
    
    let context = container.mainContext
    
    // Create course and hole
    let course = Course(name: "Test Course", par: 72)
    let hole = Hole(number: 5, par: 4, handicap: 3, distance: 420)
    hole.course = course
    course.holes.append(hole)
    
    // Create players
    let player1 = Player(name: "Player 1", handicapIndex: 10.0)
    let player2 = Player(name: "Player 2", handicapIndex: 15.0)
    
    // Create game
    let game = Game(
        name: "Match Play",
        gameType: .matchPlay,
        courseName: course.name,
        courseRating: 72.0,
        slopeRating: 130.0,
        par: 72
    )
    game.course = course
    
    // Create round
    let round = Round(
        roundNumber: 1,
        betAmount: 50.0,
        roundType: .full18
    )
    round.game = game
    
    // Create player scores with some holes played
    let score1 = PlayerScore(player: player1)
    score1.round = round
    
    let score2 = PlayerScore(player: player2)
    score2.round = round
    
    // Add some hole scores
    for i in 1...4 {
        let hs1 = HoleScore(holeNumber: i, grossScore: 4)
        hs1.playerScore = score1
        score1.holeScores.append(hs1)
        
        let hs2 = HoleScore(holeNumber: i, grossScore: i == 2 ? 6 : 5)
        hs2.playerScore = score2
        score2.holeScores.append(hs2)
    }
    
    round.scores = [score1, score2]
    
    context.insert(course)
    context.insert(hole)
    context.insert(player1)
    context.insert(player2)
    context.insert(game)
    context.insert(round)
    context.insert(score1)
    context.insert(score2)
    
    try! context.save()
    
    @State var currentScore = 4
    
    return VStack(spacing: 16) {
        LiveScoreCard(
            playerScore: score1,
            score: $currentScore,
            holeInfo: hole,
            courseHandicap: 12,
            gameType: .matchPlay,
            allScores: [score1, score2]
        )
        .padding()
    }
    .background(Color(UIColor.systemGroupedBackground))
    .modelContainer(container)
}

#Preview("Skins Game") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
        configurations: config
    )
    
    let context = container.mainContext
    
    // Create course and hole
    let course = Course(name: "Test Course", par: 72)
    let hole = Hole(number: 3, par: 3, handicap: 15, distance: 165)
    hole.course = course
    course.holes.append(hole)
    
    // Create players
    let player1 = Player(name: "Tiger", handicapIndex: 0.0)
    let player2 = Player(name: "Phil", handicapIndex: 5.0)
    let player3 = Player(name: "Rory", handicapIndex: 2.0)
    
    // Create game
    let game = Game(
        name: "Skins Game",
        gameType: .skins,
        courseName: course.name,
        courseRating: 72.0,
        slopeRating: 130.0,
        par: 72
    )
    game.course = course
    
    // Create round
    let round = Round(
        roundNumber: 1,
        betAmount: 100.0,
        roundType: .full18
    )
    round.game = game
    
    // Create player scores
    let score1 = PlayerScore(player: player1)
    score1.round = round
    let score2 = PlayerScore(player: player2)
    score2.round = round
    let score3 = PlayerScore(player: player3)
    score3.round = round
    
    // Add some hole scores
    // Hole 1: Tiger wins
    let h1s1 = HoleScore(holeNumber: 1, grossScore: 3)
    h1s1.playerScore = score1
    score1.holeScores.append(h1s1)
    
    let h1s2 = HoleScore(holeNumber: 1, grossScore: 4)
    h1s2.playerScore = score2
    score2.holeScores.append(h1s2)
    
    let h1s3 = HoleScore(holeNumber: 1, grossScore: 4)
    h1s3.playerScore = score3
    score3.holeScores.append(h1s3)
    
    // Hole 2: Tie (carry over)
    let h2s1 = HoleScore(holeNumber: 2, grossScore: 5)
    h2s1.playerScore = score1
    score1.holeScores.append(h2s1)
    
    let h2s2 = HoleScore(holeNumber: 2, grossScore: 5)
    h2s2.playerScore = score2
    score2.holeScores.append(h2s2)
    
    let h2s3 = HoleScore(holeNumber: 2, grossScore: 5)
    h2s3.playerScore = score3
    score3.holeScores.append(h2s3)
    
    round.scores = [score1, score2, score3]
    
    context.insert(course)
    context.insert(hole)
    context.insert(player1)
    context.insert(player2)
    context.insert(player3)
    context.insert(game)
    context.insert(round)
    
    try! context.save()
    
    @State var currentScore = 3
    
    return ScrollView {
        VStack(spacing: 16) {
            ForEach([score1, score2, score3]) { playerScore in
                @State var score = 3
                LiveScoreCard(
                    playerScore: playerScore,
                    score: .constant(3),
                    holeInfo: hole,
                    courseHandicap: 0,
                    gameType: .skins,
                    allScores: [score1, score2, score3]
                )
            }
        }
        .padding()
    }
    .background(Color(UIColor.systemGroupedBackground))
    .modelContainer(container)
}

#Preview("Scramble") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Player.self, Course.self, Tee.self, Hole.self, Game.self, Round.self, PlayerScore.self, HoleScore.self,
        configurations: config
    )
    
    let context = container.mainContext
    
    // Create course and hole
    let course = Course(name: "Test Course", par: 72)
    let hole = Hole(number: 1, par: 4, handicap: 7, distance: 380)
    hole.course = course
    course.holes.append(hole)
    
    // Create team players
    let player1 = Player(name: "Team Captain", handicapIndex: 5.0)
    let player2 = Player(name: "Long Hitter", handicapIndex: 12.0)
    let player3 = Player(name: "Putter", handicapIndex: 18.0)
    let player4 = Player(name: "Steady Eddie", handicapIndex: 15.0)
    
    // Create game
    let game = Game(
        name: "Scramble",
        gameType: .scramble,
        courseName: course.name,
        courseRating: 72.0,
        slopeRating: 130.0,
        par: 72
    )
    game.course = course
    
    // Create round
    let round = Round(
        roundNumber: 1,
        betAmount: 25.0,
        roundType: .full18
    )
    round.game = game
    
    // Create player scores
    let score1 = PlayerScore(player: player1)
    score1.round = round
    let score2 = PlayerScore(player: player2)
    score2.round = round
    let score3 = PlayerScore(player: player3)
    score3.round = round
    let score4 = PlayerScore(player: player4)
    score4.round = round
    
    round.scores = [score1, score2, score3, score4]
    
    context.insert(course)
    context.insert(hole)
    context.insert(player1)
    context.insert(player2)
    context.insert(player3)
    context.insert(player4)
    context.insert(game)
    context.insert(round)
    
    try! context.save()
    
    return ScrollView {
        VStack(spacing: 16) {
            Text("Scramble - Hole 1")
                .font(.headline)
            
            @State var scores = [3, 4, 5, 4]
            ForEach(Array(round.scores.enumerated()), id: \.element.id) { index, playerScore in
                LiveScoreCard(
                    playerScore: playerScore,
                    score: .constant(scores[index]),
                    holeInfo: hole,
                    courseHandicap: 0,
                    gameType: .scramble,
                    allScores: round.scores
                )
            }
        }
        .padding()
    }
    .background(Color(UIColor.systemGroupedBackground))
    .modelContainer(container)
}
