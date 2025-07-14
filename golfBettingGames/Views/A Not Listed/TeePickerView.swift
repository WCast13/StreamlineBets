//
//  TeePickerView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/23/25.
//
import SwiftUI
import SwiftData

// MARK: - TeePickerView
struct TeePickerView: View {
    let course: Course
    @Binding var selectedTee: Tee?
    @Binding var selectedGender: Gender  // ← Changed from Gender? to Gender
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Gender") {
                    Picker("Playing As", selection: $selectedGender) {
                        // ← Removed the "Select" option since Gender is no longer optional
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                }
                
                // ← Removed the conditional check for selectedGender != nil
                Section("Tees") {
                    ForEach(course.sortedTees) { tee in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(tee.name)
                                    .font(.headline)
                                
                                // ← Directly use selectedGender without unwrapping
                                Text("\(tee.rating(for: selectedGender), specifier: "%.1f") / \(tee.slope(for: selectedGender))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if tee == selectedTee {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedTee = tee
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Select Tee")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
