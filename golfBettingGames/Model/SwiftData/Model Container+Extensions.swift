//
//  Model Container+Extensions.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/25/25.
//


import Foundation
import SwiftData

// MARK: - SwiftData Model Container
extension ModelContainer {
    static var golfBettingContainer: ModelContainer = {
        let schema = Schema([
            Player.self,
            Course.self,
            Tee.self,
            Hole.self,
            Game.self,
            Round.self,
            PlayerScore.self,
            HoleScore.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
