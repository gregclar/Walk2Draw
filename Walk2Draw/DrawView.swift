//
//  DrawView.swift
//  Walk2Draw
//
//  Created by Greg Clarke on 2/6/20.
//  Copyright © 2020 Greg Clarke. All rights reserved.
//

import UIKit
import MapKit

class DrawView: UIView {
    let mapView: MKMapView
    let clearButton: UIButton
    let startStopButton: UIButton
    let shareButton: UIButton
    let distanceLabel: UILabel
    
    override init(frame: CGRect) {
        mapView = MKMapView()
        mapView.showsUserLocation = true
        
        clearButton = UIButton(type: .system)
        clearButton.setTitle("Clear", for: .normal)
        
        startStopButton = UIButton(type: .system)
        startStopButton.setTitle("Start", for: .normal)
        
        shareButton = UIButton(type: .system)
        shareButton.setTitle("Share", for: .normal)
        
        distanceLabel = UILabel()
        distanceLabel.textColor = UIColor.black
        distanceLabel.backgroundColor = UIColor.white
        distanceLabel.textAlignment = NSTextAlignment.right
        distanceLabel.text = "0.0 km"

        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        
        mapView.delegate = self
        
        let buttonStackView = UIStackView(
            arrangedSubviews: [clearButton, startStopButton, shareButton, distanceLabel])
        buttonStackView.distribution = .fillEqually
        
        let stackView = UIStackView(
            arrangedSubviews: [mapView, buttonStackView])
        stackView.axis =  .vertical
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),])
    }
    
    func addOverlay(with locations: [CLLocation]){
        mapView.removeOverlays(mapView.overlays)
        
        let coordinates = locations.map { $0.coordinate }
        let overlay = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(overlay)
        
        guard let lastLocation = locations.last else { return }
        
        let maxDistance = locations.reduce(100) {
            result, next -> Double in
            
            let distance = next.distance(from: lastLocation)
            return max(result, distance)
        }
        
        let region = MKCoordinateRegion(
            center: lastLocation.coordinate,
            latitudinalMeters:  maxDistance,
            longitudinalMeters: maxDistance)
        
        mapView.setRegion(region, animated: true)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DrawView : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView,
                rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if overlay is MKPolyline {
                let renderer = MKPolylineRenderer(overlay: overlay)
                renderer.strokeColor = .red
                renderer.lineWidth = 3
                return renderer
            } else {
                return MKOverlayRenderer(overlay: overlay)
            }
    }
}
