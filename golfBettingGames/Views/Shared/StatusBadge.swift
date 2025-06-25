//
//  StatusBadge.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/25/25.
//


import SwiftUI
import SwiftData

// MARK: - StatusBadge.swift
struct StatusBadge: View {
    let isCompleted: Bool
    
    var body: some View {
        Text(isCompleted ? "Completed" : "In Progress")
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(isCompleted ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
            .foregroundColor(isCompleted ? .green : .orange)
            .cornerRadius(12)
    }
}
