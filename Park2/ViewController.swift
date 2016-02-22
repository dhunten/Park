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

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mainActionButton: UIBarButtonItem!
    @IBOutlet weak var reminderDatePicker: UIDatePicker!
    var parkingSpot = ParkingSpot()
    var parkingSpotView = ParkingSpotView()
    var manager: CLLocationManager!
    var userLocation = CLLocationCoordinate2D()
    let dateFormatter = NSDateFormatter()


    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        reminderDatePicker.minimumDate = NSDate(timeIntervalSinceNow: 0)
        dateFormatter.dateStyle = .FullStyle
        dateFormatter.timeStyle = .ShortStyle

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
            parkingSpot.coords = CLLocationCoordinate2D(latitude: 0, longitude: 0)
            reminderDatePicker.minimumDate = NSDate(timeIntervalSinceNow: 0)
            
        } else {
            
            // Remember new loc
            parkingSpot.reminder = reminderDatePicker.date
            let dateString = dateFormatter.stringFromDate(parkingSpot.reminder)
            parkingSpotView.savePin(userLocation, title: dateString)
            updateMapView(userLocation, pin: parkingSpotView.dropPin)
            mainActionButton.title = "Forget"
            parkingSpot.coords = userLocation
            parkingSpotView.setNotification(parkingSpot.reminder)
            
        }
        
        saveToFile()

    }
    

    
    @IBAction func refreshAction(sender: UIBarButtonItem) {
        
        manager.requestLocation()
        
    }
    

    
    // When GPS data is returned
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        userLocation = locations[0].coordinate

        if let _ = parkingSpotView.dropPin {
            
            updateMapView(userLocation, pin: parkingSpotView.dropPin)
            
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
        if let ps = NSKeyedUnarchiver.unarchiveObjectWithFile(ParkingSpot.ArchiveURL.path!) as? ParkingSpot {
            
            parkingSpot = ps
            print("Loaded", parkingSpot.coords)
            
            
        }
        
        // If loaded a real coord, put the Pin there/update UI
        if (parkingSpot.coords.longitude != 0) {
            
            let dateString = dateFormatter.stringFromDate(parkingSpot.reminder)
            parkingSpotView.savePin(parkingSpot.coords, title: dateString)
            reminderDatePicker.date = parkingSpot.reminder
            
        }
    }
    
    func saveToFile() {
        
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(parkingSpot, toFile: ParkingSpot.ArchiveURL.path!)
        if isSuccessfulSave {
            
            print("Saved!", parkingSpot.coords)
            
        }
        
    }
    
}


