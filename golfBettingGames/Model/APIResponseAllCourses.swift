//
//  APIResponseAllCourses.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/23/25.
//


import Foundation

/// Top-level response model for the courses API
struct APIResponseAllCourses: Codable {
    let courses: [APICourseDetails]
    let currentPage: Int
    let perPage: Int
    let rowCount: Int
    let total: Int
    let success: Bool
    
    private enum CodingKeys: String, CodingKey {
        case courses
        case currentPage
        case perPage
        case rowCount
        case total
        case success
    }
}

struct APICourseDetails: Codable, Identifiable {
    var id = UUID() // For SwiftUI identification if needed
    var courseName: String
    var address1: String?
    var city: String?
    var state: String?
    var country: String?
    var ratings: String? // Stored as string, e.g., "[]"
    var latitude: String?
    var longitude: String?
    var telephone: String?
    var email: String?
    var website: String?
    var holes: Int?
    var lengthFormat: String?
    var scorecard: String? // JSON string, can be parsed later
    var teeBoxes: String? // JSON string, can be parsed later
    
    private enum CodingKeys: String, CodingKey {
        case courseName
        case address1
        case city
        case state
        case country
        case ratings
        case latitude
        case longitude
        case telephone
        case email
        case website
        case holes
        case lengthFormat
        case scorecard
        case teeBoxes
    }
    
    // Optional: Method to parse scorecard JSON string into an array of entries
    var parsedScorecard: [ScorecardEntry]? {
        guard let scorecard = scorecard, let data = scorecard.data(using: .utf8) else { return nil }
        do {
            return try JSONDecoder().decode([ScorecardEntry].self, from: data)
        } catch {
            print("Error parsing scorecard: \(error)")
            return nil
        }
    }
    
    // Optional: Method to parse teeBoxes JSON string into an array of entries
    var parsedTeeBoxes: [TeeBoxEntry]? {
        guard let teeBoxes = teeBoxes, let data = teeBoxes.data(using: .utf8) else { return nil }
        do {
            return try JSONDecoder().decode([TeeBoxEntry].self, from: data)
        } catch {
            print("Error parsing teeBoxes: \(error)")
            return nil
        }
    }
}

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
