//
//  Hole.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/26/25.
//


import Foundation
import SwiftData

// MARK: - Hole Model
import Foundation
import SwiftData

@Model
final class Hole {
    var id: UUID
    var number: Int
    var par: Int
    var handicap: Int
    var distance: Int // in yards
    
    // Relationship
    var course: Course?
    
    init(number: Int, par: Int, handicap: Int, distance: Int = 0) {
        self.id = UUID()
        self.number = number
        self.par = par
        self.handicap = handicap
        self.distance = distance
    }
}