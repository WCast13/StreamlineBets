//
//  CourseListView 2.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/23/25.
//


// MARK: - Course List View
import SwiftUI
import SwiftData

struct CourseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Course.name) private var courses: [Course]
    
    @State private var showingAddCourse = false
    @State private var selectedCourse: Course?
    
    var body: some View {
        NavigationStack {
            List {
                if courses.isEmpty {
                    ContentUnavailableView(
                        "No Courses",
                        systemImage: "flag.fill",
                        description: Text("Add courses to save time when creating games")
                    )
                } else {
                    ForEach(courses) { course in
                        CourseRow(course: course) {
                            selectedCourse = course
                        }
                    }
                    .onDelete(perform: deleteCourses)
                }
            }
            .navigationTitle("Courses")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add", systemImage: "plus") {
                        showingAddCourse = true
                    }
                }
            }
            .sheet(isPresented: $showingAddCourse) {
                AddCourseView()
            }
            .sheet(item: $selectedCourse) { course in
                CourseDetailView(course: course)
            }
        }
    }
    
    private func deleteCourses(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(courses[index])
        }
    }
}
