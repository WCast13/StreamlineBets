//
//  RoundType.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/25/25.
//

import Foundation

enum RoundType: String, Codable, CaseIterable {
    case front9 = "Front 9"
    case back9 = "Back 9"
    case full18 = "Full 18"
    case hole = "Single Hole"
    case custom = "Custom"
    
    var description: String {
        return self.rawValue
    }
}
