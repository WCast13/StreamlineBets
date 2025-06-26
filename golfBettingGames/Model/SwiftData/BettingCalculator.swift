//
//  BettingCalculator.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/26/25.
//


import Foundation
import SwiftData

// MARK: - BettingCalculator Protocol
protocol BettingCalculator {
    func calculateWinnings(for round: Round)
    func validateScores(for round: Round) -> Bool
    var gameType: GameType { get }
}
