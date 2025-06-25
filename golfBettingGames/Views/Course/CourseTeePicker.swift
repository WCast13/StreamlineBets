//
//  CourseTeePicker.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/24/25.
//

import SwiftUI
import SwiftData

// MARK: - Course and Tee Picker (for game creation)
struct CourseTeePicker: View {
    @Binding var selectedCourse: Course?
    @Binding var selectedTee: Tee?
    @Binding var selectedGender: Gender?
    
    @Query(sort: [
        SortDescriptor(\Course.isFavorite, order: .reverse),
        SortDescriptor(\Course.name)
    ]) private var courses: [Course]
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingTeePicker = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Course") {
                    ForEach(courses) { course in
                        HStack {
                            if course.isFavorite {
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                            }
                            
                            Text(course.name)
                            
                            Spacer()
                            
                            if course == selectedCourse {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedCourse = course
                            selectedTee = nil
                            showingTeePicker = true
                        }
                    }
                }
                
                if let course = selectedCourse, let tee = selectedTee {
                    Section("Selected") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(course.name) - \(tee.name) Tees")
                                .font(.headline)
                            
                            if let gender = selectedGender {
                                Text("\(gender.rawValue): \(tee.rating(for: gender), specifier: "%.1f") / \(tee.slope(for: gender))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Course")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .disabled(selectedCourse == nil || selectedTee == nil)
                }
            }
        }
        .sheet(isPresented: $showingTeePicker) {
            if let course = selectedCourse {
                TeePickerView(
                    course: course,
                    selectedTee: $selectedTee,
                    selectedGender: $selectedGender
                )
            }
        }
    }
}
