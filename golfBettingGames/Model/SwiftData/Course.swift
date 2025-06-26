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
    var city: String
    var state: String
    var country: String
    
    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \Tee.course)
    var tees: [Tee] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Hole.course)
    var holes: [Hole] = []
    
    @Relationship(inverse: \Game.course)
    var games: [Game] = []
    
    init(name: String, par: Int = 72, city: String = "", state: String = "", country: String = "USA") {
        self.id = UUID()
        self.name = name
        self.par = par
        self.isFavorite = false
        self.city = city
        self.state = state
        self.country = country
    }
    
    var sortedTees: [Tee] {
        tees.sorted { $0.menRating > $1.menRating }
    }
    
    var sortedHoles: [Hole] {
        holes.sorted { $0.number < $1.number }
    }
    
    var front9Par: Int {
        holes.filter { $0.number <= 9 }.reduce(0) { $0 + $1.par }
    }
    
    var back9Par: Int {
        holes.filter { $0.number > 9 }.reduce(0) { $0 + $1.par }
    }
}



