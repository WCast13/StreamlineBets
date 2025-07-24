//
//  APIResponseAllCourses.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/23/25.
//


import Foundation

/// Top-level response model for the courses API
struct APIResponseAllCourses: Codable {
    let courses: [APICourseDetails]
    let currentPage: Int
    let perPage: Int
    let rowCount: Int
    let total: Int
    let success: Bool
    
    private enum CodingKeys: String, CodingKey {
        case courses
        case currentPage
        case perPage
        case rowCount
        case total
        case success
    }
}
