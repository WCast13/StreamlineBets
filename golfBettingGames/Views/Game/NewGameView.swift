//
//  NewGameView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/20/25.
//


// MARK: - NewGameView.swift
import SwiftUI
import SwiftData

struct NewGameView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allPlayers: [Player]
    @Query(sort: \Course.name) private var courses: [Course]
    
    @State private var gameName = ""
    @State private var gameType: GameType = .skins
    @State private var selectedCourse: Course?
    @State private var selectedTee: Tee?
    @State private var selectedGender: Gender = .men
    @State private var selectedPlayers: Set<Player> = []
    @State private var showingPlayerPicker = false
    @State private var showingCoursePicker = false
    @State private var showingCourseManager = false
    
    private var canCreateGame: Bool {
        !gameName.isEmpty && selectedCourse != nil && selectedTee != nil && selectedPlayers.count >= 2
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Game Details") {
                    TextField("Game Name", text: $gameName)
                    
                    Picker("Game Type", selection: $gameType) {
                        ForEach(GameType.allCases, id: \.self) { type in
                            Text(type.description).tag(type)
                        }
                    }
                    
                    DatePicker("Date", selection: .constant(Date()), displayedComponents: .date)
                        .disabled(true)
                }
                
                Section("Course Selection") {
                    if selectedCourse == nil {
                        Button(action: { showingCoursePicker = true }) {
                            Label("Select Course", systemImage: "flag.circle")
                                .foregroundColor(.accentColor)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(selectedCourse!.name)
                                .font(.headline)
                            
                            if !selectedCourse!.city.isEmpty {
                                Text("\(selectedCourse!.city), \(selectedCourse!.state)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Text("Par \(selectedCourse!.par)")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .cornerRadius(4)
                                
                                if let tee = selectedTee {
                                    Text("\(tee.name) • \(tee.rating(for: selectedGender), specifier: "%.1f") / \(tee.slope(for: selectedGender))")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .cornerRadius(4)
                                }
                            }
                            
                            Button("Change Course") {
                                showingCoursePicker = true
                            }
                            .font(.caption)
                        }
                    }
                    
                    if courses.isEmpty {
                        Button(action: { showingCourseManager = true }) {
                            Label("Add Courses", systemImage: "plus.circle")
                                .font(.caption)
                        }
                    }
                }
                
                if selectedCourse != nil {
                    Section("Tee Selection") {
                        Picker("Playing As", selection: $selectedGender) {
                            ForEach(Gender.allCases, id: \.self) { gender in
                                Text(gender.rawValue).tag(gender)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        if let course = selectedCourse {
                            ForEach(course.sortedTees) { tee in
                                Button(action: { selectedTee = tee }) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(tee.name)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            Text("\(tee.rating(for: selectedGender), specifier: "%.1f") / \(tee.slope(for: selectedGender))")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        if selectedTee == tee {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.accentColor)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                
                Section {
                    if selectedPlayers.isEmpty {
                        Button("Select Players") {
                            showingPlayerPicker = true
                        }
                    } else {
                        ForEach(Array(selectedPlayers).sorted { $0.name < $1.name }) { player in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(player.name)
                                    
                                    if let course = selectedCourse, let tee = selectedTee {
                                        let ch = player.courseHandicap(
                                            courseRating: tee.rating(for: selectedGender),
                                            slopeRating: Double(tee.slope(for: selectedGender)),
                                            par: course.par
                                        )
                                        Text("Course Handicap: \(ch)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Button(action: { selectedPlayers.remove(player) }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        Button("Add More Players") {
                            showingPlayerPicker = true
                        }
                        .font(.caption)
                    }
                } header: {
                    Text("Players (\(selectedPlayers.count) selected)")
                } footer: {
                    if selectedPlayers.count < 2 {
                        Text("Select at least 2 players")
                            .foregroundColor(.orange)
                    }
                }
            }
            .navigationTitle("New Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { createGame() }
                        .disabled(!canCreateGame)
                }
            }
            .sheet(isPresented: $showingPlayerPicker) {
                SimplePlayerPicker(
                    players: allPlayers,
                    selectedPlayers: $selectedPlayers
                )
            }
            .sheet(isPresented: $showingCoursePicker) {
                CoursePicker(
                    selectedCourse: $selectedCourse,
                    selectedTee: $selectedTee,
                    selectedGender: $selectedGender
                )
            }
            .sheet(isPresented: $showingCourseManager) {
                CourseListView()
            }
        }
    }
    
    private func createGame() {
        guard let course = selectedCourse, let tee = selectedTee else { return }
        
        let game = Game(
            name: gameName,
            gameType: gameType,
            courseName: course.name,
            courseRating: tee.rating(for: selectedGender),
            slopeRating: Double(tee.slope(for: selectedGender)),
            par: course.par
        )
        
        game.course = course
        game.selectedTee = tee
        game.selectedGender = selectedGender
        game.players = Array(selectedPlayers)
        
        modelContext.insert(game)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save game: \(error)")
        }
    }
}

