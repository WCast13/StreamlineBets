//
//  WinningsCalculatorView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/25/25.
//


import SwiftUI
import SwiftData

// MARK: - WinningsCalculatorView.swift
struct WinningsCalculatorView: View {
    @Environment(\.dismiss) private var dismiss
    let round: Round
    let onApply: () -> Void
    
    @State private var winningsDict: [UUID: Double] = [:]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Manually adjust winnings for each player")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text("Adjust Winnings")
                }
                
                Section {
                    ForEach(round.scores) { score in
                        if let player = score.player {
                            HStack {
                                Text(player.name)
                                Spacer()
                                TextField("Amount",
                                         value: Binding(
                                            get: { winningsDict[score.id] ?? score.winnings },
                                            set: { winningsDict[score.id] = $0 }
                                         ),
                                         format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                                    .keyboardType(.numbersAndPunctuation)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 120)
                            }
                        }
                    }
                } header: {
                    Text("Player Winnings")
                } footer: {
                    let total = winningsDict.values.reduce(0, +)
                    Text("Total: \(formatCurrency(total))")
                        .foregroundColor(abs(total) < 0.01 ? .green : .orange)
                }
            }
            .navigationTitle("Winnings Calculator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        applyWinnings()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            // Initialize with current winnings
            for score in round.scores {
                winningsDict[score.id] = score.winnings
            }
        }
    }
    
    private func applyWinnings() {
        for score in round.scores {
            if let winnings = winningsDict[score.id] {
                score.winnings = winnings
            }
        }
        onApply()
        dismiss()
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

