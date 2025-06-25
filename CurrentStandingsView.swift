//
//  CurrentStandingsView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/24/25.
//

import SwiftUI
import SwiftData

// MARK: - CurrentStandingsView.swift
struct CurrentStandingsView: View {
    let game: Game
    
    private var standings: [(player: Player, total: Double)] {
        game.players.map { player in
            (player, game.totalForPlayer(player))
        }.sorted { $0.total > $1.total }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Standings")
                .font(.headline)
            
            ForEach(standings, id: \.player.id) { standing in
                StandingRow(
                    player: standing.player,
                    amount: standing.total,
                    rank: rankForAmount(standing.total)
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func rankForAmount(_ amount: Double) -> Int {
        let amounts = standings.map { $0.total }
        let uniqueAmounts = Array(Set(amounts)).sorted(by: >)
        return (uniqueAmounts.firstIndex(of: amount) ?? 0) + 1
    }
}
