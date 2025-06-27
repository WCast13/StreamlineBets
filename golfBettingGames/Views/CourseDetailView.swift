//
//  CourseDetailView.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/24/25.
//

import SwiftUI
import SwiftData

// MARK: - CourseDetailView
struct CourseDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var course: Course
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                // Overview Tab
                List {
                    Section("Course Information") {
                        LabeledContent("Name", value: course.name)
                        LabeledContent("Location", value: "\(course.city), \(course.state)")
                        LabeledContent("Par", value: "\(course.par)")
                        LabeledContent("Front 9", value: "\(course.front9Par)")
                        LabeledContent("Back 9", value: "\(course.back9Par)")
                    }
                    
                    Section("Tees") {
                        ForEach(course.sortedTees) { tee in
                            TeeDetailRow(tee: tee)
                        }
                    }
                }
                .tabItem {
                    Label("Overview", systemImage: "info.circle")
                }
                .tag(0)
                
                // Holes Tab
                List {
                    Section("Front 9") {
                        ForEach(course.sortedHoles.filter { $0.number <= 9 }) { hole in
                            HoleDetailRow(hole: hole)
                        }
                    }
                    
                    Section("Back 9") {
                        ForEach(course.sortedHoles.filter { $0.number > 9 }) { hole in
                            HoleDetailRow(hole: hole)
                        }
                    }
                }
                .tabItem {
                    Label("Holes", systemImage: "flag.fill")
                }
                .tag(1)
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
