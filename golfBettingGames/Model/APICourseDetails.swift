//
//  APICourseDetails:.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/23/25.
//

import Foundation
import Playgrounds

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
