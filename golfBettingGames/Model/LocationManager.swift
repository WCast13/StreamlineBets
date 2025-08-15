//
//  LocationManager.swift
//  golfBettingGames
//
//  Created by William Castellano on 8/12/25.
//


import Foundation
import CoreLocation
import SwiftUI
import Combine

@MainActor
class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var userLocation: CLLocation?
    @Published var nearbyCourses: [APICourseDetails] = []
    @Published var isLoadingCourses = false
    @Published var locationError: String?
    
    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Check initial authorization status
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startLocationServices() {
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .notDetermined:
            requestLocationPermission()
        case .denied, .restricted:
            locationError = "Location access denied. Enable in Settings to find nearby courses."
        @unknown default:
            locationError = "Unknown location authorization status"
        }
    }
    
    func fetchNearbyCourses() {
        guard let location = userLocation else {
            locationError = "Unable to determine your location"
            return
        }
        
        isLoadingCourses = true
        locationError = nil
        
        NetworkManager.shared.fetchCoursesByCoordinates(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            radius: 30, // 30 mile radius
            page: 1
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoadingCourses = false
                
                switch result {
                case .success(let response):
                    self?.nearbyCourses = response.courses
                    print("Found \(response.courses.count) nearby courses")
                case .failure(let error):
                    self?.locationError = "Failed to load nearby courses: \(error.localizedDescription)"
                    print("Error fetching courses: \(error)")
                }
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            locationError = "Location access denied. Enable in Settings to find nearby courses."
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
        
        // Automatically fetch nearby courses when we get location
        fetchNearbyCourses()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                locationError = "Location access denied"
            case .locationUnknown:
                locationError = "Unable to determine location"
            default:
                locationError = "Location error: \(error.localizedDescription)"
            }
        } else {
            locationError = "Failed to get location: \(error.localizedDescription)"
        }
    }
}
