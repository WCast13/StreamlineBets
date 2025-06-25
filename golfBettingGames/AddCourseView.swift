//
//  AddCourseView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/24/25.
//

import SwiftUI
import SwiftData

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

