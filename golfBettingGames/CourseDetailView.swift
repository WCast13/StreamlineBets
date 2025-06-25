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

