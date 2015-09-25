//
//  ViewController.swift
//  Park2
//
//  Created by Derek Hunten on 9/10/15.
//  Copyright © 2015 BLOOF INDUSTRIES. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import CoreData

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mainActionButton: UIBarButtonItem!
    var parkingSpot = ParkingSpot()
    var parkingSpotView = ParkingSpotView()
    var manager: CLLocationManager!
    var userLocation = CLLocationCoordinate2D()
    
    // we should be able to do this as an optional for ParkingSpot.coords
    var isParkingSpotSaved = true


    override func viewDidLoad() {
        
        super.viewDidLoad()

        mapView.delegate = self
        
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 25 //meters
        manager.requestWhenInUseAuthorization()
        
        loadCoords()
        updateMapView(parkingSpot.coords, pin: parkingSpotView.dropPin)
        
        if (isParkingSpotSaved) {
            mainActionButton.title = "Forget"
        }
    }
    

    
    @IBAction func saveAction(sender: UIBarButtonItem) {
        
        if (isParkingSpotSaved) {
            
            // Forget loc
            updateMapView(parkingSpot.coords, pin: nil)
            mainActionButton.title = "Remember"
            
        } else {
            
            // Remember new loc
            parkingSpot.saveLocation()
            updateMapView(parkingSpot.coords, pin: parkingSpotView.dropPin)
            mainActionButton.title = "Forget"
        }
        isParkingSpotSaved = !isParkingSpotSaved
    }
    

    
    @IBAction func refreshAction(sender: UIBarButtonItem) {
        
        manager.requestLocation()
        parkingSpotView.setReminder(parkingSpot.reminder)
        
    }
    

    
    // When GPS data is returned
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //print("\(locations[0])")
        userLocation = locations[0].coordinate

        //parkingSpotView.dropPin.coordinate = parkingSpot.coords
        parkingSpotView.dropPin.title = title

        if (isParkingSpotSaved) {
            
            updateMapView(userLocation, pin: parkingSpotView.dropPin)
            
            print("\(parkingSpot.coords) &&&& \(parkingSpotView.dropPin.coordinate)")
            
        } else {
            
            updateMapView(userLocation, pin: nil)
        }
    }
    
    
    
    // Needs an error funciton too, so xcode is happy
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print(error)
        
    }
    
    func updateMapView(centerCoords: CLLocationCoordinate2D, pin: MKAnnotation?) {
        
        if let 📍 = pin {

            let p1 = MKMapPointForCoordinate(📍.coordinate)
            let p2 = MKMapPointForCoordinate(centerCoords)
            let mapRect = MKMapRectMake(fmin(p1.x,p2.x), fmin(p1.y,p2.y), fabs(p1.x-p2.x), fabs(p1.y-p2.y)) // bc the MapRect only expands to the right & up
            
            mapView.addAnnotation(📍)
            mapView.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
            
        } else {
            
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(centerCoords, 20.0,  20.0)
            mapView.setRegion(coordinateRegion, animated: true)
            mapView.removeAnnotation(parkingSpotView.dropPin)
            
        }
        
    }
    
    
    func loadCoords() {
        parkingSpot.loadLocation()
        parkingSpotView.dropPin.coordinate = parkingSpot.coords
    }
    
}


