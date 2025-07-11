//
//  PlayerScorecardRow.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/11/25.
//


import SwiftUI
import SwiftData

struct PlayerScorecardRow: View {
    @Bindable var playerScore: PlayerScore
    let currentHoleNumber: Int
    @Binding var scores: [UUID: Int]
    let front9Holes: [Hole]
    let back9Holes: [Hole]
    
    private var playerName: String {
        if let name = playerScore.player?.name {
            return String(name.prefix(10))
        }
        return "Unknown"
    }
    
    private var front9Score: Int {
        var total = 0
        for hole in 1...9 {
            if let holeScore = playerScore.holeScores.first(where: { $0.holeNumber == hole }) {
                total += holeScore.grossScore
            } else if hole == currentHoleNumber, let currentScore = scores[playerScore.id], currentScore > 0 {
                total += currentScore
            }
        }
        return total
    }
    
    private var back9Score: Int {
        var total = 0
        for hole in 10...18 {
            if let holeScore = playerScore.holeScores.first(where: { $0.holeNumber == hole }) {
                total += holeScore.grossScore
            } else if hole == currentHoleNumber, let currentScore = scores[playerScore.id], currentScore > 0 {
                total += currentScore
            }
        }
        return total
    }
    
    private var totalScore: Int {
        front9Score + back9Score
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Text(playerName)
                .frame(width: 80, alignment: .leading)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 8)
                .lineLimit(1)
            
            // Front 9 scores
            ForEach(1...9, id: \.self) { holeNum in
                if let holeScore = playerScore.holeScores.first(where: { $0.holeNumber == holeNum }) {
                    ScoreCell(
                        score: holeScore.grossScore,
                        par: front9Holes.first(where: { $0.number == holeNum })?.par,
                        isCurrentHole: false
                    )
                } else if holeNum == currentHoleNumber, let currentScore = scores[playerScore.id], currentScore > 0 {
                    ScoreCell(
                        score: currentScore,
                        par: front9Holes.first(where: { $0.number == holeNum })?.par,
                        isCurrentHole: true
                    )
                } else {
                    Text("-")
                        .frame(width: 30)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Front 9 total
            Text(front9Score > 0 ? "\(front9Score)" : "-")
                .frame(width: 40)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Divider()
                .frame(width: 1)
                .padding(.horizontal, 4)
            
            // Back 9 scores
            ForEach(10...18, id: \.self) { holeNum in
                if let holeScore = playerScore.holeScores.first(where: { $0.holeNumber == holeNum }) {
                    ScoreCell(
                        score: holeScore.grossScore,
                        par: back9Holes.first(where: { $0.number == holeNum })?.par,
                        isCurrentHole: false
                    )
                } else if holeNum == currentHoleNumber, let currentScore = scores[playerScore.id], currentScore > 0 {
                    ScoreCell(
                        score: currentScore,
                        par: back9Holes.first(where: { $0.number == holeNum })?.par,
                        isCurrentHole: true
                    )
                } else {
                    Text("-")
                        .frame(width: 30)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Back 9 total
            Text(back9Score > 0 ? "\(back9Score)" : "-")
                .frame(width: 40)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            // Total
            Text(totalScore > 0 ? "\(totalScore)" : "-")
                .frame(width: 40)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.green)
        }
        .padding(.vertical, 6)
    }
}

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
    
    // Add some hole scores
    for i in 1...7 {
        let hs1 = HoleScore(holeNumber: i, grossScore: i == 2 ? 3 : 4)
        hs1.playerScore = score1
        score1.holeScores.append(hs1)
        
        let hs2 = HoleScore(holeNumber: i, grossScore: i == 5 ? 2 : 5)
        hs2.playerScore = score2
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
        score2.id: 6
    ]
    
    return VStack {
        LiveScorecardView(
            round: round,
            currentHoleNumber: 8,
            scores: $scores
        )
        .padding()
    }
    .background(Color(UIColor.systemGroupedBackground))
    .modelContainer(container)
}
