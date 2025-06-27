//
//  BettingSection.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/19/25.
//

import SwiftUI

struct BettingSection: View {
    @Binding var betAmount: Double
    
    private let quickBetAmounts = [5, 10, 20, 50, 100]
    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    var body: some View {
        Section("Betting") {
            HStack {
                Text("Bet Amount")
                Spacer()
                TextField("Amount",
                         value: $betAmount,
                         format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 120)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(quickBetAmounts, id: \.self) { amount in
                        QuickBetButton(
                            amount: amount,
                            isSelected: betAmount == Double(amount),
                            formatter: currencyFormatter
                        ) {
                            betAmount = Double(amount)
                        }
                    }
                }
            }
        }
    }
}
