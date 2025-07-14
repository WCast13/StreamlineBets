//
//  RoundSetupViewModel.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/19/25.
//

// MARK: - RoundSetupViewModel.swift
import SwiftUI

@Observable
class RoundSetupViewModel {
    var roundType: RoundType = .hole
    var roundNumber: Int = 1
    var holeNumber: Int = 1
    var betAmount: Double = 10.0
    var selectedPlayers: Set<Player> = []
    
    var canCreateRound: Bool {
        selectedPlayers.count >= 2 && betAmount > 0
    }
    
    func updateRoundNumber(for game: Game, roundType: RoundType) {
        if roundType == .hole {
            let holeRounds = game.rounds.filter { $0.roundType == .hole }
            roundNumber = holeRounds.count + 1
        }
    }
    
    func createRound(for game: Game) -> Round {
        let round = Round(
            roundNumber: roundNumber,
            holeNumber: roundType == .hole ? holeNumber : nil,
            betAmount: betAmount,
            roundType: roundType
        )
        round.game = game
        return round
    }
}

