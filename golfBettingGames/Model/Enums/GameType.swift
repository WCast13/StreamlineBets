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
    // Team or Individual game types
    case matchPlay = "Match Play"
    case nassau = "Nassau"
    case skins = "Skins"
    
    // Team only game types
    case scramble = "Scramble"  // Best score of the team counts
    
    var description: String {
        return self.rawValue
    }
    
    // ADDED: Helper to identify team-only game types
    var isTeamOnly: Bool {
        switch self {
        case .scramble:
            return true
        default:
            return false
        }
    }
    
    // ADDED: Helper to identify games that can be played as team or individual
    var supportsTeamPlay: Bool {
        // All current game types support team play
        return true
    }
    
    // ADDED: Helper to identify if this game type can be played individually
    var supportsIndividualPlay: Bool {
        switch self {
        case .matchPlay, .nassau, .skins:
            return true
        case .scramble:
            return false
        }
    }
}
