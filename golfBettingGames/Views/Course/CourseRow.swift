//
//  CourseRow.swift
//  golfBettingGames
//
//  Created by William Castellano on 6/23/25.
//

import SwiftUI
import SwiftData

//// MARK: - CourseRow
//struct CourseRow: View {
//    @Bindable var course: Course
//    let onTap: () -> Void
//    
//    var body: some View {
//        Button(action: onTap) {
//            HStack {
//                Button(action: { course.isFavorite.toggle() }) {
//                    Image(systemName: course.isFavorite ? "star.fill" : "star")
//                        .foregroundColor(course.isFavorite ? .yellow : .gray)
//                }
//                .buttonStyle(.plain)
//                
//                VStack(alignment: .leading, spacing: 4) {
//                    Text(course.name)
//                        .font(.headline)
//                        .foregroundColor(.primary)
//                    
//                    HStack {
//                        Text("Par \(course.par)")
//                        Text("•")
//                        Text("\(course.tees.count) tees")
//                    }
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                }
//                
//                Spacer()
//                
//                Image(systemName: "chevron.right")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            }
//            .padding(.vertical, 4)
//        }
//        .buttonStyle(.plain)
//    }
//}
