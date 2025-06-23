//
//  StagingView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/20/25.
//

// MARK: - Tee Model
import Foundation
import SwiftData
import SwiftUI





// MARK: - AddCourseView
struct AddCourseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var courseName = ""
    @State private var par = 72
    @State private var tees: [TeeData] = [TeeData()]
    
    struct TeeData: Identifiable {
        let id = UUID()
        var name = "White"
        var menRating = 72.0
        var menSlope = 113
        var womenRating = 72.0
        var womenSlope = 113
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Course Information") {
                    TextField("Course Name", text: $courseName)
                    Stepper("Par: \(par)", value: $par, in: 60...80)
                }
                
                ForEach($tees) { $tee in
                    Section("Tee: \(tee.name)") {
                        Picker("Tee Color", selection: $tee.name) {
                            ForEach(["Black", "Blue", "White", "Gold", "Red"], id: \.self) { color in
                                Text(color).tag(color)
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Men's Ratings")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                TextField("Rating", value: $tee.menRating,
                                         format: .number.precision(.fractionLength(1)))
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                                
                                Text("/")
                                
                                TextField("Slope", value: $tee.menSlope, format: .number)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Women's Ratings")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                TextField("Rating", value: $tee.womenRating,
                                         format: .number.precision(.fractionLength(1)))
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                                
                                Text("/")
                                
                                TextField("Slope", value: $tee.womenSlope, format: .number)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                    }
                }
                
                Button("Add Another Tee") {
                    tees.append(TeeData())
                }
            }
            .navigationTitle("New Course")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveCourse() }
                        .disabled(courseName.isEmpty || tees.isEmpty)
                }
            }
        }
    }
    
    private func saveCourse() {
        let course = Course(name: courseName.trimmingCharacters(in: .whitespaces), par: par)
        
        for teeData in tees {
            let tee = Tee(
                name: teeData.name,
                menRating: teeData.menRating,
                menSlope: teeData.menSlope,
                womenRating: teeData.womenRating,
                womenSlope: teeData.womenSlope
            )
            tee.course = course
            course.tees.append(tee)
            modelContext.insert(tee)
        }
        
        modelContext.insert(course)
        dismiss()
    }
}

// MARK: - CourseDetailView
struct CourseDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var course: Course
    
    var body: some View {
        NavigationStack {
            List {
                Section("Course Information") {
                    LabeledContent("Name", value: course.name)
                    LabeledContent("Par", value: "\(course.par)")
                }
                
                Section("Tees") {
                    ForEach(course.sortedTees) { tee in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(tee.name)
                                .font(.headline)
                            
                            HStack(spacing: 20) {
                                VStack(alignment: .leading) {
                                    Text("Men")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(tee.menRating, specifier: "%.1f") / \(tee.menSlope)")
                                        .font(.subheadline)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Women")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(tee.womenRating, specifier: "%.1f") / \(tee.womenSlope)")
                                        .font(.subheadline)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle(course.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

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


