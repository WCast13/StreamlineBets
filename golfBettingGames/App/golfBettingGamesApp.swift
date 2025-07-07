//
//  golfBettingGamesApp.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/19/25.
//

import SwiftUI
import SwiftData

@main
struct golfBettingGamesApp: App {
    let container = ModelContainer.golfBettingContainer
    
    init() {
        // Create initial data if needed
        if let context = try? container.mainContext {
            DataInitializer.createInitialDataIfNeeded(in: context)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
