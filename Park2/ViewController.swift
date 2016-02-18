//
//  ViewController.swift
//  Park2
//
//  Created by Derek Hunten on 9/10/15.
//  Copyright © 2015 BLOOF INDUSTRIES. All rights reserved.
//

//let interval = ["Every","1st","2nd","3rd","4th","1st & 3rd","2nd & 4th"]
//let day = ["Monday","Tuesday","Wednesday","Thursday","Friday"]

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


    override func viewDidLoad() {
        
        super.viewDidLoad()

        mapView.delegate = self
        
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 25 //meters
        manager.requestWhenInUseAuthorization()
        
        loadCoords()
        manager.requestLocation()
        
        if let _ = parkingSpotView.dropPin {
            mainActionButton.title = "Forget"
        }
    }
    

    
    @IBAction func saveAction(sender: UIBarButtonItem) {
        
        // Is there a pin on the map?
        if let _ = parkingSpotView.dropPin  {
            
            // Forget loc
            mapView.removeAnnotation(parkingSpotView.dropPin!)
            parkingSpotView.dropPin = nil
            updateMapView(userLocation, pin: nil)
            mainActionButton.title = "Remember"
            
        } else {
            
            // Remember new loc
            parkingSpotView.savePin(userLocation)
            updateMapView(userLocation, pin: parkingSpotView.dropPin)
            mainActionButton.title = "Forget"
            parkingSpot.coords = userLocation
            
            // Save to file
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(parkingSpot, toFile: ParkingSpot.ArchiveURL.path!)
            if isSuccessfulSave {
                print("Saved!", parkingSpot.coords)
            }
        }

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
        //parkingSpotView.dropPin?.title = title

        if let _ = parkingSpotView.dropPin {
            
            updateMapView(userLocation, pin: parkingSpotView.dropPin)
            //print("GPS return. UserLoc: \(userLocation), pin: \(parkingSpotView.dropPin?.coordinate)")
            
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
            
        }
        
    }
    
    
    func loadCoords() {
        
        // Load from file
        parkingSpot = NSKeyedUnarchiver.unarchiveObjectWithFile(ParkingSpot.ArchiveURL.path!) as! ParkingSpot
        print("Loaded", parkingSpot.coords)
        
        // If loaded a real coord, put the Pin there
        if (parkingSpot.coords.longitude != 0) {
            
            parkingSpotView.savePin(parkingSpot.coords)
        }
    }
    
}


