//
//  GameType.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/25/25.
//


import Foundation
import SwiftData



// MARK: - Enums
enum GameType: String, Codable, CaseIterable {
    case skins = "Skins"
    case nassau = "Nassau"
    case matchPlay = "Match Play"
    case strokePlay = "Stroke Play"
    case scramble = "Scramble"
    
    
    case wolf = "Wolf"
    case bestBall = "Best Ball"
    
    case custom = "Custom"
    
    var description: String {
        return self.rawValue
    }
}
