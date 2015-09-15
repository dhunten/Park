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
    @IBOutlet weak var save: UIBarButtonItem!
    @IBOutlet weak var load: UIBarButtonItem!

    
    var manager: CLLocationManager!
    var corelocations = [NSManagedObject]()
    var tempLocation = CLLocation()
    //var managedObjectContext: NSManagedObjectContext!
    let dropPin = MKPointAnnotation()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Setup our Map View
        mapView.delegate = self
        
        
        //Setup our Location Manager
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 25 //meters
        manager.requestWhenInUseAuthorization()
        //        manager.startUpdatingLocation()
        refreshLocation()
        
    }
    
    
    func refreshLocation() {
        manager.requestLocation()
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("\(locations[0])")
        tempLocation = locations[0]
        
        
        // Update the map's viewable region
        let initialLocation = locations[0]
        let regionRadius: CLLocationDistance = 10
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: false)
        
        // Drop a pin at current location
        // TODO: reuse the pin so there aren't multiples
        dropPin.coordinate = initialLocation.coordinate
        dropPin.title = "My Parking Spot"
        mapView.addAnnotation(dropPin)
    }
    
    
    
    // Needs an error funciton too, so xcode is happy
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("ruh roh")
    }
    
    
    
    // Save a location to core data
    func saveLocation(location: CLLocation) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let entity = NSEntityDescription.entityForName("Car", inManagedObjectContext: managedContext)
        let carManagedObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        carManagedObject.setValue(location.coordinate.latitude, forKey: "lat")
        carManagedObject.setValue(location.coordinate.longitude, forKey: "long")
        
        print("Attempting to save lat: \(location.coordinate.latitude), long: \(location.coordinate.longitude)")
        
        do {
            // TODO: just keep one instance of Car, currently it just keeps appending more to core data
            try managedContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    
    
    // Load data from core data
    func loadLocation() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let moc = appDelegate.managedObjectContext
        let locationsFetch = NSFetchRequest(entityName: "Car")
        
        do {
            let fetchedLocation = try moc.executeFetchRequest(locationsFetch)
            let fetchedLat = fetchedLocation.last!.valueForKey("lat")
            let fetchedLong = fetchedLocation.last!.valueForKey("long")
            print("Lat: \(fetchedLat!), Long: \(fetchedLong!)")
            
//            for item in fetchedLocation {
//                let fetchedLat = item.valueForKey("lat")
//                let fetchedLong = item.valueForKey("long")
//                print("Lat: \(fetchedLat!), Long: \(fetchedLong!)")
//            }
            
            
        } catch {
            fatalError("Failed to fetch: \(error)")
        }
        
        
        
    }
    
    
    
    @IBAction func saveAction(sender: UIBarButtonItem) {
        saveLocation(tempLocation)
    }
    
    
    @IBAction func loadAction(sender: UIBarButtonItem) {
        loadLocation()
    }

    
    @IBAction func refreshAction(sender: UIBarButtonItem) {
        refreshLocation()
    }
}

