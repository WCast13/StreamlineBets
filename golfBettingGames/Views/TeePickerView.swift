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
    @Binding var selectedGender: Gender?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Gender") {
                    Picker("Playing As", selection: $selectedGender) {
                        Text("Select").tag(nil as Gender?)
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender as Gender?)
                        }
                    }
                }
                
                if selectedGender != nil {
                    Section("Tees") {
                        ForEach(course.sortedTees) { tee in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(tee.name)
                                        .font(.headline)
                                    
                                    if let gender = selectedGender {
                                        Text("\(tee.rating(for: gender), specifier: "%.1f") / \(tee.slope(for: gender))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
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
