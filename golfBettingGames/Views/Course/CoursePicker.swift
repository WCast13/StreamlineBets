//
//  CoursePicker.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/27/25.
//

import SwiftUI
import SwiftData

struct CoursePicker: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Course.name) private var courses: [Course]
    
    @Binding var selectedCourse: Course?
    @Binding var selectedTee: Tee?
    @Binding var selectedGender: Gender
    
    @State private var showingAddCourse = false
    @State private var showingTeeSelection = false
    
    @State private var tempSelectedCourse: Course?
    
    var body: some View {
        NavigationStack {
            List {
                if courses.isEmpty {
                    ContentUnavailableView(
                        "No Courses",
                        systemImage: "flag.fill",
                        description: Text("Add courses to select from")
                    )
                } else {
                    Section {
                        ForEach(courses) { course in
                            Button(action: {
                                selectedCourse = course
                                selectedTee = nil
                                showingTeeSelection = true
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(course.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        HStack {
                                            Text("Par \(course.par)")
                                            if !course.city.isEmpty {
                                                Text("•")
                                                Text("\(course.city), \(course.state)")
                                            }
                                        }
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if course == selectedCourse {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.accentColor)
                                    } else {
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    } header: {
                        Text("Available Courses")
                    }
                }
            }
            .navigationTitle("Select Course")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Add", systemImage: "plus") {
                        showingAddCourse = true
                    }
                }
            }
            .sheet(isPresented: $showingAddCourse) {
                AddCourseView()
            }
            .sheet(isPresented: $showingTeeSelection) {
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
}
