//
//  ContentView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/19/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Query private var players: [Player]
    @Query private var games: [Game]
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
