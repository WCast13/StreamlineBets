// MARK: - Enhanced AddCourseView
import SwiftUI
import SwiftData

struct AddCourseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var courseName = ""
    @State private var par = 72
    @State private var tees: [TeeData] = [TeeData()]
    @State private var holes: [HoleData] = []
    @State private var showingHoleEditor = false
    
    struct TeeData: Identifiable {
        let id = UUID()
        var name = "White"
        var menRating = 72.0
        var menSlope = 113
        var womenRating = 72.0
        var womenSlope = 113
    }
    
    struct HoleData: Identifiable {
        let id = UUID()
        var number: Int
        var par = 4
        var handicap = 1
        var yardage = 400
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Course Information") {
                    TextField("Course Name", text: $courseName)
                    
                    HStack {
                        Text("Total Par")
                        Spacer()
                        Text("\(par)")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Tees Section
                Section("Tees") {
                    ForEach($tees) { $tee in
                        TeeRow(tee: $tee)
                    }
                    .onDelete(perform: deleteTee)
                    
                    Button("Add Tee") {
                        tees.append(TeeData())
                    }
                }
                
                // Holes Section
                Section("Holes") {
                    if holes.isEmpty {
                        Button("Generate Default 18 Holes") {
                            generateDefaultHoles()
                        }
                    } else {
                        Button("Edit Hole Details") {
                            showingHoleEditor = true
                        }
                        
                        HStack {
                            Text("Front 9")
                            Spacer()
                            Text("Par \(front9Par)")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Back 9")
                            Spacer()
                            Text("Par \(back9Par)")
                                .foregroundColor(.secondary)
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
            .sheet(isPresented: $showingHoleEditor) {
                HoleEditorView(holes: $holes, totalPar: $par)
            }
        }
    }
    
    private var front9Par: Int {
        holes.prefix(9).reduce(0) { $0 + $1.par }
    }
    
    private var back9Par: Int {
        holes.suffix(9).reduce(0) { $0 + $1.par }
    }
    
    private func generateDefaultHoles() {
        holes = []
        for i in 1...18 {
            let hole = HoleData(
                number: i,
                par: defaultPar(for: i),
                handicap: defaultHandicap(for: i),
                yardage: defaultYardage(for: i)
            )
            holes.append(hole)
        }
        updateTotalPar()
    }
    
    private func defaultPar(for hole: Int) -> Int {
        // Mix of par 3s, 4s, and 5s
        switch hole {
        case 3, 8, 12, 17: return 3
        case 2, 5, 11, 14: return 5
        default: return 4
        }
    }
    
    private func defaultHandicap(for hole: Int) -> Int {
        // Standard handicap allocation
        let handicaps = [5, 11, 1, 15, 7, 17, 3, 13, 9, 6, 12, 2, 16, 8, 18, 4, 14, 10]
        return handicaps[hole - 1]
    }
    
    private func defaultYardage(for hole: Int) -> Int {
        switch defaultPar(for: hole) {
        case 3: return Int.random(in: 150...210)
        case 4: return Int.random(in: 350...450)
        case 5: return Int.random(in: 480...580)
        default: return 400
        }
    }
    
    private func updateTotalPar() {
        par = holes.reduce(0) { $0 + $1.par }
    }
    
    private func deleteTee(at offsets: IndexSet) {
        tees.remove(atOffsets: offsets)
    }
    
    private func saveCourse() {
        let course = Course(name: courseName.trimmingCharacters(in: .whitespaces), par: par)
        
        // Clear default holes if we have custom ones
        if !holes.isEmpty {
            course.holes.removeAll()
        }
        
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
        if !holes.isEmpty {
            for holeData in holes {
                let hole = Hole(
                    number: holeData.number,
                    par: holeData.par,
                    handicap: holeData.handicap,
                    yardage: holeData.yardage
                )
                hole.course = course
                course.holes.append(hole)
                modelContext.insert(hole)
            }
        }
        
        modelContext.insert(course)
        dismiss()
    }
}

// MARK: - TeeRow Component
struct TeeRow: View {
    @Binding var tee: AddCourseView.TeeData
    
    var body: some View {
        VStack(spacing: 12) {
            Picker("Tee Color", selection: $tee.name) {
                ForEach(["Black", "Blue", "White", "Gold", "Red", "Green"], id: \.self) { color in
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
        .padding(.vertical, 4)
    }
}

// MARK: - HoleEditorView
import SwiftUI

struct HoleEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var holes: [AddCourseView.HoleData]
    @Binding var totalPar: Int
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("Total Par")
                        Spacer()
                        Text("\(totalPar)")
                            .fontWeight(.semibold)
                            .foregroundColor(.accentColor)
                    }
                } header: {
                    Text("Course Summary")
                }
                
                Section {
                    ForEach($holes) { $hole in
                        HoleDetailRow(hole: $hole, onUpdate: updateTotalPar)
                    }
                } header: {
                    HStack {
                        Text("Hole")
                            .frame(width: 50, alignment: .leading)
                        Text("Par")
                            .frame(width: 50, alignment: .center)
                        Text("Hdcp")
                            .frame(width: 50, alignment: .center)
                        Text("Yards")
                            .frame(width: 80, alignment: .trailing)
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Edit Holes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func updateTotalPar() {
        totalPar = holes.reduce(0) { $0 + $1.par }
    }
}

// MARK: - HoleDetailRow
struct HoleDetailRow: View {
    @Binding var hole: AddCourseView.HoleData
    let onUpdate: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            Text("\(hole.number)")
                .frame(width: 50, alignment: .leading)
                .font(.subheadline)
            
            Picker("", selection: $hole.par) {
                ForEach(3...5, id: \.self) { par in
                    Text("\(par)").tag(par)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 100)
            .onChange(of: hole.par) { _, _ in
                onUpdate()
            }
            
            Picker("", selection: $hole.handicap) {
                ForEach(1...18, id: \.self) { hdcp in
                    Text("\(hdcp)").tag(hdcp)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 60)
            
            TextField("Yards", value: $hole.yardage, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
                .textFieldStyle(.roundedBorder)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - ScorecardView
import SwiftUI
import SwiftData

struct ScorecardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var round: Round
    @State private var selectedPlayer: PlayerScore?
    @State private var showingQuickEntry = false
    
    private var course: Course? {
        round.game?.course
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Course Header
                    if let game = round.game {
                        CourseHeaderView(game: game)
                    }
                    
                    // Scorecard Grid
                    ScorecardGrid(round: round, selectedPlayer: $selectedPlayer)
                        .padding(.horizontal)
                    
                    // Quick Actions
                    HStack(spacing: 16) {
                        Button(action: { showingQuickEntry = true }) {
                            Label("Quick Entry", systemImage: "square.and.pencil")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button(action: calculateResults) {
                            Label("Calculate", systemImage: "function")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .disabled(!allScoresEntered)
                    }
                    .padding()
                }
            }
            .navigationTitle("Scorecard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        saveAndDismiss()
                    }
                }
            }
            .sheet(isPresented: $showingQuickEntry) {
                QuickScoreEntryView(round: round)
            }
            .sheet(item: $selectedPlayer) { player in
                PlayerScorecardView(playerScore: player, round: round)
            }
        }
    }
    
    private var allScoresEntered: Bool {
        round.scores.allSatisfy { playerScore in
            playerScore.holeScores.allSatisfy { $0.grossScore > 0 }
        }
    }
    
    private func saveAndDismiss() {
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save: \(error)")
        }
    }
    
    private func calculateResults() {
        // Update total scores for all players
        for playerScore in round.scores {
            playerScore.updateTotalScores()
        }
        
        // Calculate winnings based on game type
        if let game = round.game {
            switch game.gameType {
            case .skins:
                calculateSkinsResults()
            case .nassau:
                calculateNassauResults()
            default:
                calculateSkinsResults() // Default
            }
        }
        
        round.isCompleted = true
    }
    
    private func calculateSkinsResults() {
        // Implementation for skins game calculation
        let totalPot = round.betAmount * Double(round.scores.count)
        let lowestScore = round.scores.map { $0.netScore }.min() ?? 0
        let winners = round.scores.filter { $0.netScore == lowestScore }
        
        if winners.count == 1 {
            for score in round.scores {
                if score.netScore == lowestScore {
                    score.winnings = totalPot - round.betAmount
                } else {
                    score.winnings = -round.betAmount
                }
            }
        } else {
            // Tie - no money changes hands
            for score in round.scores {
                score.winnings = 0
            }
        }
    }
    
    private func calculateNassauResults() {
        // Implementation for Nassau game calculation
        // Front 9, Back 9, and Total
        // This is a simplified version - you can expand this
    }
}

// MARK: - CourseHeaderView
struct CourseHeaderView: View {
    let game: Game
    
    var body: some View {
        VStack(spacing: 8) {
            Text(game.courseName)
                .font(.title2)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                if let course = game.course {
                    Label("Par \(course.par)", systemImage: "flag.fill")
                }
                
                if let tee = game.selectedTee {
                    Label(tee.name, systemImage: "location.fill")
                }
                
                Label("\(game.effectiveRating, specifier: "%.1f") / \(game.effectiveSlope)",
                      systemImage: "gauge")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical)
    }
}

// MARK: - ScorecardGrid
struct ScorecardGrid: View {
    let round: Round
    @Binding var selectedPlayer: PlayerScore?
    
    private var course: Course? {
        round.game?.course
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Row
            ScorecardHeaderRow()
            
            Divider()
            
            // Hole Info
            if let course = course {
                HoleInfoRow(holes: Array(course.sortedHoles.prefix(9)), label: "Hole")
                HoleInfoRow(holes: Array(course.sortedHoles.prefix(9)), label: "Par", keyPath: \.par)
                HoleInfoRow(holes: Array(course.sortedHoles.prefix(9)), label: "Hdcp", keyPath: \.handicap)
                
                Divider().padding(.vertical, 4)
            }
            
            // Player Scores
            ForEach(round.scores) { playerScore in
                PlayerScoreRow(playerScore: playerScore, holes: 1...9) {
                    selectedPlayer = playerScore
                }
                Divider()
            }
            
            // Back 9
            if let course = course, course.holes.count == 18 {
                Divider().padding(.vertical, 8)
                
                HoleInfoRow(holes: Array(course.sortedHoles.suffix(9)), label: "Hole", startingAt: 10)
                HoleInfoRow(holes: Array(course.sortedHoles.suffix(9)), label: "Par", keyPath: \.par)
                HoleInfoRow(holes: Array(course.sortedHoles.suffix(9)), label: "Hdcp", keyPath: \.handicap)
                
                Divider().padding(.vertical, 4)
                
                ForEach(round.scores) { playerScore in
                    PlayerScoreRow(playerScore: playerScore, holes: 10...18) {
                        selectedPlayer = playerScore
                    }
                    Divider()
                }
            }
        }
        .font(.system(.body, design: .monospaced))
    }
}

// MARK: - Supporting Views
struct ScorecardHeaderRow: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("Player")
                .frame(width: 120, alignment: .leading)
                .font(.caption)
                .fontWeight(.semibold)
            
            ForEach(1...9, id: \.self) { hole in
                Text("\(hole)")
                    .frame(width: 35)
                    .font(.caption)
            }
            
            Text("Out")
                .frame(width: 45)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
    }
}

struct HoleInfoRow: View {
    let holes: [Hole]
    let label: String
    var keyPath: KeyPath<Hole, Int>?
    var startingAt: Int = 1
    
    var body: some View {
        HStack(spacing: 0) {
            Text(label)
                .frame(width: 120, alignment: .leading)
                .font(.caption)
                .foregroundColor(.secondary)
            
            ForEach(holes) { hole in
                if let keyPath = keyPath {
                    Text("\(hole[keyPath: keyPath])")
                        .frame(width: 35)
                        .font(.caption2)
                } else {
                    Text("\(startingAt + holes.firstIndex(where: { $0.id == hole.id })!)")
                        .frame(width: 35)
                        .font(.caption2)
                }
            }
            
            if let keyPath = keyPath {
                let total = holes.reduce(0) { $0 + $1[keyPath: keyPath] }
                Text("\(total)")
                    .frame(width: 45)
                    .font(.caption)
                    .fontWeight(.medium)
            } else {
                Text("")
                    .frame(width: 45)
            }
        }
        .padding(.vertical, 4)
    }
}

struct PlayerScoreRow: View {
    let playerScore: PlayerScore
    let holes: ClosedRange<Int>
    let onTap: () -> Void
    
    private var displayScores: [Int] {
        holes.map { holeNum in
            playerScore.holeScores.first(where: { $0.holeNumber == holeNum })?.grossScore ?? 0
        }
    }
    
    private var totalForRange: Int {
        displayScores.reduce(0, +)
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                Text(playerScore.player?.name ?? "Unknown")
                    .frame(width: 120, alignment: .leading)
                    .font(.subheadline)
                    .lineLimit(1)
                
                ForEach(Array(zip(holes, displayScores)), id: \.0) { holeNum, score in
                    Text(score > 0 ? "\(score)" : "-")
                        .frame(width: 35)
                        .font(.subheadline)
                        .foregroundColor(score == 0 ? .secondary : .primary)
                }
                
                Text(totalForRange > 0 ? "\(totalForRange)" : "-")
                    .frame(width: 45)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - QuickScoreEntryView
import SwiftUI
import SwiftData

struct QuickScoreEntryView: View {
    @Environment(\.dismiss) private var dismiss
    let round: Round
    
    @State private var currentHole = 1
    @State private var scores: [UUID: Int] = [:]
    @State private var putts: [UUID: Int] = [:]
    
    private var course: Course? {
        round.game?.course
    }
    
    private var currentHoleInfo: Hole? {
        course?.holes.first(where: { $0.number == currentHole })
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Hole Navigation
                HoleNavigationView(
                    currentHole: $currentHole,
                    totalHoles: course?.holes.count ?? 18,
                    holeInfo: currentHoleInfo
                )
                
                Divider()
                
                // Score Entry
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(round.scores) { playerScore in
                            PlayerScoreEntryCard(
                                playerScore: playerScore,
                                currentHole: currentHole,
                                score: binding(for: playerScore.id, in: $scores),
                                putts: binding(for: playerScore.id, in: $putts),
                                holeInfo: currentHoleInfo
                            )
                        }
                    }
                    .padding()
                }
                
                // Navigation Buttons
                HStack(spacing: 16) {
                    Button(action: previousHole) {
                        Label("Previous", systemImage: "chevron.left")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(currentHole == 1)
                    
                    Button(action: nextHole) {
                        Label("Next", systemImage: "chevron.right")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(currentHole == (course?.holes.count ?? 18))
                }
                .padding()
            }
            .navigationTitle("Quick Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        saveScores()
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadCurrentScores()
        }
    }
    
    private func binding(for playerId: UUID, in dict: Binding<[UUID: Int]>) -> Binding<Int> {
        Binding(
            get: { dict.wrappedValue[playerId] ?? 0 },
            set: { dict.wrappedValue[playerId] = $0 }
        )
    }
    
    private func loadCurrentScores() {
        for playerScore in round.scores {
            if let holeScore = playerScore.holeScores.first(where: { $0.holeNumber == currentHole }) {
                scores[playerScore.id] = holeScore.grossScore
                putts[playerScore.id] = holeScore.putts
            }
        }
    }
    
    private func saveCurrentHoleScores() {
        for playerScore in round.scores {
            let score = scores[playerScore.id] ?? 0
            let puttCount = putts[playerScore.id] ?? 0
            
            if let existingScore = playerScore.holeScores.first(where: { $0.holeNumber == currentHole }) {
                existingScore.grossScore = score
                existingScore.putts = puttCount
            } else if score > 0 {
                let holeScore = HoleScore(
                    holeNumber: currentHole,
                    grossScore: score,
                    putts: puttCount
                )
                holeScore.playerScore = playerScore
                holeScore.hole = currentHoleInfo
                playerScore.holeScores.append(holeScore)
            }
        }
    }
    
    private func previousHole() {
        saveCurrentHoleScores()
        currentHole = max(1, currentHole - 1)
        loadCurrentScores()
    }
    
    private func nextHole() {
        saveCurrentHoleScores()
        currentHole = min(course?.holes.count ?? 18, currentHole + 1)
        loadCurrentScores()
    }
    
    private func saveScores() {
        saveCurrentHoleScores()
        for playerScore in round.scores {
            playerScore.updateTotalScores()
        }
    }
}

// MARK: - HoleNavigationView
struct HoleNavigationView: View {
    @Binding var currentHole: Int
    let totalHoles: Int
    let holeInfo: Hole?
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Hole \(currentHole)")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if let hole = holeInfo {
                HStack(spacing: 20) {
                    Label("Par \(hole.par)", systemImage: "flag.fill")
                    Label("\(hole.yardage) yds", systemImage: "location.fill")
                    Label("Hdcp \(hole.handicap)", systemImage: "number.circle")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            
            // Hole dots indicator
            HStack(spacing: 4) {
                ForEach(1...totalHoles, id: \.self) { hole in
                    Circle()
                        .fill(hole == currentHole ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(width: hole == currentHole ? 8 : 6,
                               height: hole == currentHole ? 8 : 6)
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
    }
}

// MARK: - PlayerScoreEntryCard
struct PlayerScoreEntryCard: View {
    let playerScore: PlayerScore
    let currentHole: Int
    @Binding var score: Int
    @Binding var putts: Int
    let holeInfo: Hole?
    
    private var strokesOnHole: Int {
        guard let player = playerScore.player,
              let round = playerScore.round,
              let game = round.game,
              let hole = holeInfo else { return 0 }
        
        let courseHandicap = player.courseHandicap(
            courseRating: game.effectiveRating,
            slopeRating: Double(game.effectiveSlope),
            par: game.par
        )
        
        return courseHandicap >= hole.handicap ? 1 : 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(playerScore.player?.name ?? "Unknown")
                    .font(.headline)
                
                Spacer()
                
                if strokesOnHole > 0 {
                    Text("Gets \(strokesOnHole) stroke(s)")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            HStack(spacing: 20) {
                // Gross Score
                VStack(alignment: .leading) {
                    Text("Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        ForEach(1...10, id: \.self) { num in
                            Button(action: { score = num }) {
                                Text("\(num)")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(score == num ? .semibold : .regular)
                                    .frame(width: 32, height: 32)
                                    .background(
                                        score == num ? Color.accentColor : Color.gray.opacity(0.2)
                                    )
                                    .foregroundColor(score == num ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Putts
                VStack(alignment: .leading) {
                    Text("Putts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        ForEach(0...4, id: \.self) { num in
                            Button(action: { putts = num }) {
                                Text("\(num)")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(putts == num ? .semibold : .regular)
                                    .frame(width: 32, height: 32)
                                    .background(
                                        putts == num ? Color.green : Color.gray.opacity(0.2)
                                    )
                                    .foregroundColor(putts == num ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            
            if score > 0 && strokesOnHole > 0 {
                HStack {
                    Text("Net Score: \(score - strokesOnHole)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - PlayerScorecardView
import SwiftUI
import SwiftData

struct PlayerScorecardView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var playerScore: PlayerScore
    let round: Round
    
    @State private var editingHole: Int?
    
    private var course: Course? {
        round.game?.course
    }
    
    private var player: Player? {
        playerScore.player
    }
    
    private var courseHandicap: Int {
        guard let player = player,
              let game = round.game else { return 0 }
        
        return player.courseHandicap(
            courseRating: game.effectiveRating,
            slopeRating: Double(game.effectiveSlope),
            par: game.par
        )
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Player Info Card
                    PlayerInfoCard(
                        player: player,
                        courseHandicap: courseHandicap,
                        totalScore: playerScore.score,
                        totalPutts: playerScore.totalPutts
                    )
                    
                    // Front 9
                    ScorecardSection(
                        title: "Front 9",
                        holes: 1...9,
                        course: course,
                        playerScore: playerScore,
                        courseHandicap: courseHandicap,
                        editingHole: $editingHole
                    )
                    
                    // Back 9
                    if let course = course, course.holes.count == 18 {
                        ScorecardSection(
                            title: "Back 9",
                            holes: 10...18,
                            course: course,
                            playerScore: playerScore,
                            courseHandicap: courseHandicap,
                            editingHole: $editingHole
                        )
                    }
                    
                    // Summary
                    ScorecardSummary(playerScore: playerScore, course: course)
                }
                .padding()
            }
            .navigationTitle(player?.name ?? "Player Scorecard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        playerScore.updateTotalScores()
                        dismiss()
                    }
                }
            }
            .sheet(item: $editingHole) { holeNumber in
                HoleScoreEditView(
                    playerScore: playerScore,
                    holeNumber: holeNumber,
                    hole: course?.holes.first(where: { $0.number == holeNumber }),
                    courseHandicap: courseHandicap
                )
            }
        }
    }
}

// MARK: - PlayerInfoCard
struct PlayerInfoCard: View {
    let player: Player?
    let courseHandicap: Int
    let totalScore: Int
    let totalPutts: Int
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(player?.name ?? "Unknown")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Handicap Index: \(player?.handicapIndex ?? 0, specifier: "%.1f")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("CH: \(courseHandicap)")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                    
                    Text("Course Handicap")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            HStack(spacing: 30) {
                StatView(label: "Gross", value: totalScore > 0 ? "\(totalScore)" : "-")
                StatView(label: "Net", value: totalScore > 0 ? "\(totalScore - courseHandicap)" : "-")
                StatView(label: "Putts", value: totalPutts > 0 ? "\(totalPutts)" : "-")
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - StatView
struct StatView: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - ScorecardSection
struct ScorecardSection: View {
    let title: String
    let holes: ClosedRange<Int>
    let course: Course?
    let playerScore: PlayerScore
    let courseHandicap: Int
    @Binding var editingHole: Int?
    
    private var sectionHoles: [Hole] {
        course?.holes.filter { holes.contains($0.number) }
            .sorted { $0.number < $1.number } ?? []
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            VStack(spacing: 0) {
                // Header
                HStack(spacing: 0) {
                    Text("Hole")
                        .frame(width: 50, alignment: .leading)
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    ForEach(holes, id: \.self) { hole in
                        Text("\(hole)")
                            .frame(width: 35)
                            .font(.caption)
                    }
                    
                    Text("Total")
                        .frame(width: 50)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                
                // Par Row
                HStack(spacing: 0) {
                    Text("Par")
                        .frame(width: 50, alignment: .leading)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(sectionHoles) { hole in
                        Text("\(hole.par)")
                            .frame(width: 35)
                            .font(.caption2)
                    }
                    
                    Text("\(sectionHoles.reduce(0) { $0 + $1.par })")
                        .frame(width: 50)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.vertical, 4)
                
                // Score Row
                HStack(spacing: 0) {
                    Text("Score")
                        .frame(width: 50, alignment: .leading)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(holes, id: \.self) { holeNum in
                        Button(action: { editingHole = holeNum }) {
                            if let holeScore = playerScore.holeScores.first(where: { $0.holeNumber == holeNum }) {
                                Text("\(holeScore.grossScore)")
                                    .frame(width: 35)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            } else {
                                Text("-")
                                    .frame(width: 35)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    
                    let total = holes.compactMap { holeNum in
                        playerScore.holeScores.first(where: { $0.holeNumber == holeNum })?.grossScore
                    }.reduce(0, +)
                    
                    Text(total > 0 ? "\(total)" : "-")
                        .frame(width: 50)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 8)
                
                // Putts Row
                HStack(spacing: 0) {
                    Text("Putts")
                        .frame(width: 50, alignment: .leading)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(holes, id: \.self) { holeNum in
                        if let holeScore = playerScore.holeScores.first(where: { $0.holeNumber == holeNum }),
                           holeScore.putts > 0 {
                            Text("\(holeScore.putts)")
                                .frame(width: 35)
                                .font(.caption2)
                                .foregroundColor(.green)
                        } else {
                            Text("-")
                                .frame(width: 35)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    let totalPutts = holes.compactMap { holeNum in
                        playerScore.holeScores.first(where: { $0.holeNumber == holeNum })?.putts
                    }.reduce(0, +)
                    
                    Text(totalPutts > 0 ? "\(totalPutts)" : "-")
                        .frame(width: 50)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
                .padding(.vertical, 4)
            }
            .font(.system(.body, design: .monospaced))
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
        }
    }
}

// MARK: - ScorecardSummary
struct ScorecardSummary: View {
    let playerScore: PlayerScore
    let course: Course?
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Summary")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                SummaryItem(label: "Front 9", value: playerScore.front9Score)
                SummaryItem(label: "Back 9", value: playerScore.back9Score)
                SummaryItem(label: "Total", value: playerScore.score, isHighlighted: true)
            }
            
            if playerScore.winnings != 0 {
                Divider()
                
                HStack {
                    Text("Winnings")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(formatCurrency(playerScore.winnings))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(playerScore.winnings > 0 ? .green : .red)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

// MARK: - SummaryItem
struct SummaryItem: View {
    let label: String
    let value: Int
    var isHighlighted = false
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value > 0 ? "\(value)" : "-")
                .font(isHighlighted ? .title : .title2)
                .fontWeight(isHighlighted ? .bold : .semibold)
                .foregroundColor(isHighlighted ? .accentColor : .primary)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - HoleScoreEditView
import SwiftUI
import SwiftData

struct HoleScoreEditView: View {
    @Environment(\.dismiss) private var dismiss
    let playerScore: PlayerScore
    let holeNumber: Int
    let hole: Hole?
    let courseHandicap: Int
    
    @State private var grossScore: Int
    @State private var putts: Int
    @State private var fairwayHit: Bool
    @State private var greenInRegulation: Bool
    
    private var strokesOnHole: Int {
        guard let hole = hole else { return 0 }
        return courseHandicap >= hole.handicap ? 1 : 0
    }
    
    init(playerScore: PlayerScore, holeNumber: Int, hole: Hole?, courseHandicap: Int) {
        self.playerScore = playerScore
        self.holeNumber = holeNumber
        self.hole = hole
        self.courseHandicap = courseHandicap
        
        if let existingScore = playerScore.holeScores.first(where: { $0.holeNumber == holeNumber }) {
            _grossScore = State(initialValue: existingScore.grossScore)
            _putts = State(initialValue: existingScore.putts)
            _fairwayHit = State(initialValue: existingScore.fairwayHit)
            _greenInRegulation = State(initialValue: existingScore.greenInRegulation)
        } else {
            _grossScore = State(initialValue: hole?.par ?? 4)
            _putts = State(initialValue: 2)
            _fairwayHit = State(initialValue: false)
            _greenInRegulation = State(initialValue: false)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Hole \(holeNumber)")
                            .font(.headline)
                        
                        Spacer()
                        
                        if let hole = hole {
                            VStack(alignment: .trailing) {
                                Text("Par \(hole.par)")
                                Text("Hdcp \(hole.handicap)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    if strokesOnHole > 0 {
                        Label("Gets \(strokesOnHole) stroke(s)", systemImage: "info.circle")
                            .foregroundColor(.blue)
                    }
                } header: {
                    Text("Hole Information")
                }
                
                Section {
                    Stepper("Gross Score: \(grossScore)",
                           value: $grossScore,
                           in: 1...12)
                    
                    if strokesOnHole > 0 {
                        HStack {
                            Text("Net Score")
                            Spacer()
                            Text("\(grossScore - strokesOnHole)")
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }
                    }
                } header: {
                    Text("Score")
                }
                
                Section {
                    Stepper("Putts: \(putts)",
                           value: $putts,
                           in: 0...6)
                    
                    Toggle("Fairway Hit", isOn: $fairwayHit)
                        .disabled(hole?.par == 3)
                    
                    Toggle("Green in Regulation", isOn: $greenInRegulation)
                } header: {
                    Text("Statistics")
                }
            }
            .navigationTitle("Edit Score")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveScore()
                    }
                }
            }
        }
    }
    
    private func saveScore() {
        if let existingScore = playerScore.holeScores.first(where: { $0.holeNumber == holeNumber }) {
            existingScore.grossScore = grossScore
            existingScore.putts = putts
            existingScore.fairwayHit = fairwayHit
            existingScore.greenInRegulation = greenInRegulation
        } else {
            let holeScore = HoleScore(
                holeNumber: holeNumber,
                grossScore: grossScore,
                putts: putts
            )
            holeScore.fairwayHit = fairwayHit
            holeScore.greenInRegulation = greenInRegulation
            holeScore.playerScore = playerScore
            holeScore.hole = hole
            playerScore.holeScores.append(holeScore)
        }
        
        playerScore.updateTotalScores()
        dismiss()
    }
}

// MARK: - Enhanced RoundSetupView
import SwiftUI
import SwiftData

