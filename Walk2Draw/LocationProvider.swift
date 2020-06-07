//
//  LocationProvider.swift
//  Walk2Draw
//
//  Created by Greg Clarke on 1/6/20.
//  Copyright © 2020 Greg Clarke. All rights reserved.
//

import UIKit
import CoreLocation
import LogStore

class LocationProvider: NSObject, CLLocationManagerDelegate {
    private let locationManager: CLLocationManager
    private let updateHandler: (CLLocation) -> Void
    private(set) var updating = false
    
    init(updateHandler: @escaping (CLLocation) -> Void) {
        locationManager = CLLocationManager()
        self.updateHandler = updateHandler

        super.init()
    
        locationManager.delegate = self
        locationManager.distanceFilter = 1
        locationManager.requestWhenInUseAuthorization()
    }
    
    func start() {
        locationManager.startUpdatingLocation()
        updating = true
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
        updating = false
        locationManager.allowsBackgroundLocationUpdates = false
    }
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            printLog("success")
        case .denied:
            printLog("denied")
            // to be implemented later
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        updateHandler(location)
    }
}
