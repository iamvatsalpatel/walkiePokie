//
//  LocationManager.swift
//  WalkiePokie
//
//  Created by Vatsal Vipulkumar Patel on 7/22/23.
//
//
//import Foundation
//import ArcGIS
//import CoreLocation
//
//class LocationManager: ObservableObject {
//    @Published var latitude: Double = 0.0
//    @Published var longitude: Double = 0.0
//    var locationDisplay = LocationDisplay(dataSource: SystemLocationDataSource())
//
//    func currentLocation() async {
//        let locationManager = CLLocationManager()
//        locationManager.requestWhenInUseAuthorization()
//        do {
//            try await locationDisplay.dataSource.start()
//            DispatchQueue.main.async {
//                self.latitude = (self.locationDisplay.location?.position.x) ?? 0.0
//                self.longitude = (self.locationDisplay.location?.position.y) ?? 0.0
//                self.locationDisplay.initialZoomScale = 72_000
//                self.locationDisplay.autoPanMode = .recenter
//            }
//        } catch {
//            print(error)
//        }
//    }
//
//    func centerToCurrentLocation() {
//        locationDisplay.autoPanMode = .recenter
//    }
//}

import Foundation
import CoreLocation
import ArcGIS

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.location = location
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
        }
    }
}
