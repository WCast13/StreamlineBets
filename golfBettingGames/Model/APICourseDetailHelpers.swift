//
//  ScorecardEntry.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/23/25.
//

import Foundation

/// Model for a scorecard entry (based on the JSON structure)
struct ScorecardEntry: Codable {
    let par: Int?
    let hole: Int?
    let tees: TeesDict?
    let handicap: Int?
    
    private enum CodingKeys: String, CodingKey {
        case par = "Par"
        case hole = "Hole"
        case tees
        case handicap = "Handicap"
    }
}

/// Dictionary for tees in scorecard
struct TeesDict: Codable {
    let teeBox1: TeeBox?
}

/// Model for a tee box in scorecard
struct TeeBox: Codable {
    let color: String?
    let yards: Int?
}

/// Model for a tee box entry (based on the JSON structure)
struct TeeBoxEntry: Codable {
    let name: String?
    let slope: String?
    let rating: String?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case slope
        case rating
    }
}
