//
//  ScoringTipView.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/8/25.
//

import SwiftUI

struct ScoringTipView: View {
    @State private var showingTip = true
    
    var body: some View {
        if showingTip {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Quick Scoring Tip")
                            .font(.headline)
                        
                        Text("Use the + and - buttons to adjust scores. Defaults to par for each hole.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            showingTip = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .imageScale(.large)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
            .padding(.horizontal)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

#Preview {
    ScoringTipView()
}
