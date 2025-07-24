//
//  APICourseDetails:.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/23/25.
//

import Foundation

struct APICourseDetails: Codable, Identifiable {
    let id = UUID() // For SwiftUI identification if needed
    let courseName: String
    let address1: String?
    let city: String?
    let state: String?
    let country: String?
    let ratings: String // Stored as string, e.g., "[]"
    let latitude: String?
    let longitude: String?
    let telephone: String?
    let email: String?
    let website: String?
    let holes: Int?
    let lengthFormat: String?
    let scorecard: String? // JSON string, can be parsed later
    let teeBoxes: String? // JSON string, can be parsed later
    
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
