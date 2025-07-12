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
    @State private var city = ""
    @State private var state = ""
    @State private var country = "USA"
    @State private var tees: [TeeData] = []
    @State private var newTee = TeeData()
    @State private var holes: [HoleData] = []
    @State private var useStandardHoles = true // TODO: - Fix this section to add pars and handicaps
    
    struct TeeData: Identifiable {
        enum Gender {
            case men, women
        }
        
        let id = UUID()
        var selectedGender: Gender = .men
        var isCustomTee: Bool = false
        var customTeeName: String = ""
        var name = "White"
        var menRating = 71.2
        var menSlope = 127
        var womenRating = 72.0
        var womenSlope = 134
    }
    
    struct HoleData: Identifiable {
        let id = UUID()
        var number: Int
        var par = 4
        var handicap = 1
        var distance = 350
    }
    
    var totalPar: Int {
        holes.reduce(0) { $0 + $1.par }
    }
    
    var body: some View {
        NavigationStack {
            
            Form {
                Section("Course Information") {
                    TextField("Course Name", text: $courseName)
                    //                       TextField("City", text: $city)
                    //                       TextField("State", text: $state)
                    //                       TextField("Country", text: $country)
                }
                
                Section("Add Tee") {
                    VStack(alignment: .leading, spacing: 12) {
                        Picker("Gender", selection: $newTee.selectedGender) {
                            Text("Men's").tag(TeeData.Gender.men)
                            Text("Women's").tag(TeeData.Gender.women)
                        }
                        .pickerStyle(.segmented)
                        
                        Picker("Tee", selection: Binding(
                            get: { newTee.isCustomTee ? "Custom" : newTee.name },
                            set: { newValue in
                                if newValue == "Custom" {
                                    newTee.isCustomTee = true
                                    newTee.name = newTee.customTeeName
                                } else {
                                    newTee.isCustomTee = false
                                    newTee.name = newValue
                                }
                            })
                        ) {
                            ForEach(["Black", "Blue", "White", "Gold", "Red", "Green", "Custom"], id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        if newTee.isCustomTee {
                            TextField("Custom Tee Name", text: $newTee.customTeeName)
                                .onChange(of: newTee.customTeeName) { _, newValue in
                                    newTee.name = newValue
                                }
                        }
                        
                        if newTee.selectedGender == .men {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Men's Ratings")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    TextField("Rating", value: $newTee.menRating,
                                              format: .number.precision(.fractionLength(1)))
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                                    
                                    Text("/")
                                    
                                    TextField("Slope", value: $newTee.menSlope, format: .number)
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Women's Ratings")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    TextField("Rating", value: $newTee.womenRating,
                                              format: .number.precision(.fractionLength(1)))
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                                    
                                    Text("/")
                                    
                                    TextField("Slope", value: $newTee.womenSlope, format: .number)
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    
                    Button("Add Tee") {
                        tees.append(newTee)
                        newTee = TeeData()
                    }
                    .disabled(newTee.name.isEmpty)
                }
                
                Section("Tees") {
                    if tees.isEmpty {
                        Text("No tees added yet.")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(tees) { tee in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(tee.isCustomTee ? tee.customTeeName : tee.name)
                                    .font(.headline)
                                if tee.selectedGender == .men {
                                    Text("Men: Rating \(String(format: "%.1f", tee.menRating)), Slope \(tee.menSlope)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("Women: Rating \(String(format: "%.1f", tee.womenRating)), Slope \(tee.womenSlope)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 6)
                        }
                        .onDelete(perform: deleteTee)
                    }
                }
                
                Section("Holes") {
                    Toggle("Use Standard 18 Holes", isOn: $useStandardHoles)
                        .onChange(of: useStandardHoles) { _, newValue in
                            if newValue {
                                generateStandardHoles()
                            }
                        }
                    
                    if !useStandardHoles && !holes.isEmpty {
                        ForEach($holes) { $hole in
                            HStack {
                                Text("Hole \(hole.number)")
                                    .frame(width: 60)
                                
                                Picker("Par", selection: $hole.par) {
                                    ForEach(3...5, id: \.self) { par in
                                        Text("\(par)").tag(par)
                                    }
                                }
                                .pickerStyle(.segmented)
                                
                                Stepper("Hdcp: \(hole.handicap)", value: $hole.handicap, in: 1...18)
                            }
                        }
                    }
                    
                    if !holes.isEmpty {
                        HStack {
                            Text("Total Par")
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(totalPar)")
                                .fontWeight(.semibold)
                                .foregroundColor(totalPar == 72 ? .green : .orange)
                        }
                    }
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
        .onAppear {
            if useStandardHoles {
                generateStandardHoles()
            }
        }
    }
    
    private func generateStandardHoles() {
        holes = []
        // Standard par distribution: 4 par 3s, 10 par 4s, 4 par 5s
        let standardPars = [4, 4, 3, 4, 5, 4, 4, 3, 5, 4, 4, 3, 5, 4, 4, 4, 3, 5]
        let standardHandicaps = [7, 11, 15, 1, 5, 13, 17, 9, 3, 8, 12, 16, 2, 6, 14, 10, 18, 4]
        
        for i in 0..<18 {
            holes.append(HoleData(
                number: i + 1,
                par: standardPars[i],
                handicap: standardHandicaps[i],
                distance: standardPars[i] == 3 ? 150 : (standardPars[i] == 4 ? 380 : 520)
            ))
        }
    }
    
    private func deleteTee(at offsets: IndexSet) {
        tees.remove(atOffsets: offsets)
    }
    
    private func saveCourse() {
        let course = Course(
            name: courseName.trimmingCharacters(in: .whitespaces),
            par: totalPar,
            city: city,
            state: state,
            country: country
        )
        
        // Add tees
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
        
        // Add holes
        for holeData in holes {
            let hole = Hole(
                number: holeData.number,
                par: holeData.par,
                handicap: holeData.handicap,
                distance: holeData.distance
            )
            hole.course = course
            course.holes.append(hole)
            modelContext.insert(hole)
        }
        
        modelContext.insert(course)
        dismiss()
    }
}
