//
//  DrawViewController.swift
//  Walk2Draw
//
//  Created by Greg Clarke on 2/6/20.
//  Copyright © 2020 Greg Clarke. All rights reserved.
//

import UIKit
import LogStore
import CoreLocation
import MapKit

class DrawViewController: UIViewController {
    
    private var locationProvider: LocationProvider? = nil
    private var locations: [CLLocation] = []
    private var totalMetresTravelled: Double = 0
    private var metresTravelled: Double = 0
    
    @IBOutlet weak var distanceLabel:UILabel?
    
    private var contentView: DrawView {
        view as! DrawView
    }
    
    override func loadView() {
        let contentView = DrawView(frame: .zero)
        
        contentView.startStopButton.addTarget(
            self,
            action: #selector(startStop(_:)),
            for: .touchUpInside)
        
        contentView.clearButton.addTarget(
            self,
            action: #selector(clear(_:)),
            for: .touchUpInside)
        
        contentView.shareButton.addTarget(
            self,
            action: #selector(share(_:)),
            for: .touchUpInside)
        
        //contentView.distanceLabel.text = "loadView"
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationProvider = LocationProvider(
            updateHandler: { [weak self] location in
                guard let self = self else { return }
                
                //self.metresTravelled = self.locations.last?.distance(from: location) as! Double
                if self.locations.last != nil {
                    self.metresTravelled = self.locations.last?.distance(from: location) as! Double
                } else {
                    printLog("Starting out with no previous location")
                    self.metresTravelled = 0
                }
                self.totalMetresTravelled += self.metresTravelled
                //printLog("distance: \(String(describing: self.locations.last?.distance(from: location))) metres")
                printLog("total km: \(String(describing: self.totalMetresTravelled/1000))")
                //printLog("location: \(location)")
                self.contentView.distanceLabel.text = "viewDidLoad"
                self.contentView.distanceLabel.text = String(format:"%f", self.totalMetresTravelled/1000)
                self.locations.append(location)
                self.contentView.addOverlay(with: self.locations)
        })
    }

    @objc func startStop(_ sender: UIButton) {
        guard let locationProvider = locationProvider else {fatalError()}
        if locationProvider.updating {
            locationProvider.stop()
            sender.setTitle("Start", for: .normal)
        } else {
            locationProvider.start()
            sender.setTitle("Stop", for: .normal)
        }
    }
    
    @objc func clear(_ sender: UIButton) {
        locations.removeAll()
        self.totalMetresTravelled = 0.0
        contentView.addOverlay(with: locations)
        totalMetresTravelled = 0
    }
    
    @objc func share(_ sender: UIButton) {
        if locations.isEmpty {
            return
        }
        let options = MKMapSnapshotter.Options()
        options.region = contentView.mapView.region
        
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, error in
            guard let snapshot = snapshot else {
                return
            }
            let image = self.imageByAddingPath(with: self.locations, to: snapshot)
            let activity = UIActivityViewController(activityItems: [image, "Walk2Draw"], applicationActivities: nil)
            self.present(activity, animated: true)
        }
        
    }
    
    func imageByAddingPath(
        with locations: [CLLocation],
        to snapshot: MKMapSnapshotter.Snapshot)
        -> UIImage {
            UIGraphicsBeginImageContextWithOptions(snapshot.image.size, true, snapshot.image.scale)
            snapshot.image.draw(at: .zero)
            let bezierPath = UIBezierPath()
            guard let firstCoordinate = locations.first?.coordinate else {
                fatalError("locations array is empty")
            }
             let firstPoint = snapshot.point(for: firstCoordinate)
            bezierPath.move(to: firstPoint)
            for location in locations.dropFirst() {
                let point = snapshot.point(for: location.coordinate)
                bezierPath.addLine(to: point)
            }
            UIColor.purple.setStroke()
            bezierPath.lineWidth = 2
            bezierPath.stroke()
            
            guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
                fatalError("could not get image from context")
            }
            UIGraphicsEndImageContext()
            return image
            }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


