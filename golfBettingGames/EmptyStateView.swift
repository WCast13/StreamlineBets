//
//  EmptyStateView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/20/25.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.golf")
                .font(.system(size: 80))
                .foregroundColor(.secondary)
            
            Text("Select a game to view details")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Create a new game to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
    }
}
