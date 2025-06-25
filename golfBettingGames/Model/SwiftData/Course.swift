//
//  Course.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/25/25.
//


import Foundation
import SwiftData

// MARK: - Course Model
@Model
final class Course {
    var id: UUID
    var name: String
    var par: Int
    var isFavorite: Bool
    
    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \Tee.course)
    var tees: [Tee] = []
    
    @Relationship(inverse: \Game.course)
    var games: [Game] = []
    
    init(name: String, par: Int = 72) {
        self.id = UUID()
        self.name = name
        self.par = par
        self.isFavorite = false
    }
    
    var sortedTees: [Tee] {
        tees.sorted { $0.menRating > $1.menRating }
    }
}
