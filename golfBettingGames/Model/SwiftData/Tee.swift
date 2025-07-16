//
//  Tee.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/25/25.
//

import Foundation
import SwiftData

// MARK: - Tee Model
@Model

final class Tee {
    var id: UUID
    var name: String
    var menRating: Double
    var menSlope: Int
    var womenRating: Double
    var womenSlope: Int
    
    // Relationship
    var course: Course?
    
    init(
        name: String,
        menRating: Double = 72.0,
        menSlope: Int = 113,
        womenRating: Double = 72.0,
        womenSlope: Int = 113
    ) {
        self.id = UUID()
        self.name = name
        self.menRating = menRating
        self.menSlope = menSlope
        self.womenRating = womenRating
        self.womenSlope = womenSlope
    }
    
    func rating(for gender: Gender) -> Double {
        switch gender {
        case .men: return menRating
        case .women: return womenRating
        }
    }
    
    func slope(for gender: Gender) -> Int {
        switch gender {
        case .men: return menSlope
        case .women: return womenSlope
        }
    }
}
import Foundation
import SwiftData

