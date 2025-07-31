//
//  GrokResponse Course Manager.swift
//  golfBettingGames
//
//  Created by William Castellano on 7/23/25.
//

import Foundation

// MARK: - Network Manager

/// Network manager class for handling API requests
class NetworkManager {
    static let shared = NetworkManager()
     
    private init() {}
    
    private let baseURL = "https://zylalabs.com/api/2029/golf+courses+data+api/"
    private let apiKey = "5958|UvW3e4nwFNwO7sEVeo7TVMPGfzJZrPOojRi8Dwql" // Replace with your actual API key
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        return URLSession(configuration: config)
    }()
    
    private func createRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func performRequest<T: Decodable>(with request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let serverError = NSError(domain: "Server Error", code: statusCode, userInfo: nil)
                DispatchQueue.main.async {
                    completion(.failure(serverError))
                }
                return
            }
            
            guard let data = data else {
                let noDataError = NSError(domain: "No Data", code: -1, userInfo: nil)
                DispatchQueue.main.async {
                    completion(.failure(noDataError))
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let responseObject = try decoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(responseObject))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    /// Fetches golf courses by name
    /// - Parameters:
    ///   - name: The name of the golf course
    ///   - completion: Completion handler with result
    func fetchCoursesByName(name: String, completion: @escaping (Result<APIResponseAllCourses, Error>) -> Void) {
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "\(baseURL)3594/golf+courses+by+name?filter[courseName]=\(encodedName)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        let request = createRequest(for: url)
        performRequest(with: request, completion: completion)
    }
    
    /// Fetches golf courses by coordinates
    /// - Parameters:
    ///   - latitude: Latitude coordinate
    ///   - longitude: Longitude coordinate
    ///   - radius: Search radius (max 50)
    ///   - page: Page number for pagination
    ///   - completion: Completion handler with result
    func fetchCoursesByCoordinates(latitude: Double, longitude: Double, radius: Int = 50, page: Int = 1, completion: @escaping (Result<APIResponseAllCourses, Error>) -> Void) {
        guard radius <= 50 else {
            completion(.failure(NSError(domain: "Invalid Parameter", code: -1, userInfo: ["message": "Radius must be <= 50"])))
            return
        }
        
        guard let url = URL(string: "\(baseURL)3595/golf+courses+by+coordinates?radius=\(radius)&latitude=\(latitude)&longitude=\(longitude)&page=\(page)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        let request = createRequest(for: url)
        performRequest(with: request, completion: completion)
    }
    
    /// Fetches golf clubs by state or province
    /// - Parameters:
    ///   - state: State or province name
    ///   - perPage: Number of items per page
    ///   - page: Page number for pagination
    ///   - completion: Completion handler with result
    func fetchCoursesByState(state: String, perPage: Int = 250, page: Int = 1, completion: @escaping (Result<APIResponseAllCourses, Error>) -> Void) {
        let encodedState = state.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "\(baseURL)3600/golf+clubs+by+state+or+province?filter[state]=\(encodedState)&per_page=\(perPage)&page=\(page)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        let request = createRequest(for: url)
        performRequest(with: request, completion: completion)
    }
    
    /// Fetches golf clubs by city
    /// - Parameters:
    ///   - city: City name
    ///   - page: Page number for pagination
    ///   - completion: Completion handler with result
    func fetchCoursesByCity(city: String, page: Int = 1, completion: @escaping (Result<APIResponseAllCourses, Error>) -> Void) {
        let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "\(baseURL)3601/golf+clubs+by+city?filter[city]=\(encodedCity)&page=\(page)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        let request = createRequest(for: url)
        performRequest(with: request, completion: completion)
    }
    
    let usStates = [
        "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"
    ]
}
