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
    let dropPin = MKPointAnnotation()


    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Setup our Map View
        mapView.delegate = self
        
        // Setup our Location Manager
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 25 //meters
        manager.requestWhenInUseAuthorization()
        
        // Ask for our location
        refreshLocation()
        
    }
    
    
    func refreshLocation() {
        
        manager.requestLocation()
        
    }
    
    
    
    func updatePinAndMap(latitude: Double, longitude: Double) {
        
        // Update the map's viewable region
        let newLocation = CLLocation(latitude: latitude, longitude: longitude)
        let regionRadius: CLLocationDistance = 10
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: false)
        
        // Drop a pin at current location
        dropPin.coordinate = newLocation.coordinate
        dropPin.title = "My Parking Spot"
        mapView.addAnnotation(dropPin)
    }
    
    
    
    // When GPS data is returned
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("\(locations[0])")
        tempLocation = locations[0]
        
        updatePinAndMap(tempLocation.coordinate.latitude, longitude: tempLocation.coordinate.longitude)

    }
    
    
    
    // Needs an error funciton too, so xcode is happy
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print(error)
        
    }
    
    
    
    // Save a location to core data
    func saveLocation(location: CLLocation) {
        
        // Setup the managed object context (core data)
        let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        // Setup the entry we're inserting into core data
        let entity = NSEntityDescription.entityForName("Car", inManagedObjectContext: moc)
        let carManagedObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: moc)
        
        // Add the data into the entry
        carManagedObject.setValue(location.coordinate.latitude, forKey: "lat")
        carManagedObject.setValue(location.coordinate.longitude, forKey: "long")
        
        print("Attempting to save lat: \(location.coordinate.latitude), long: \(location.coordinate.longitude)")
        
        do {
            // Save the entry into core data
            // TODO: just keep one instance of Car, currently it just keeps appending more to core data
            try moc.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    
    
    // Load data from core data
    func loadLocation() -> (Double, Double) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let moc = appDelegate.managedObjectContext
        let locationsFetch = NSFetchRequest(entityName: "Car")
        
        do {
            let fetchedLocation = try moc.executeFetchRequest(locationsFetch)
            let fetchedLat = fetchedLocation.last!.valueForKey("lat") as! Double
            let fetchedLong = fetchedLocation.last!.valueForKey("long") as! Double
            print("Lat: \(fetchedLat), Long: \(fetchedLong)")
            
            return (fetchedLat, fetchedLong)
            
        } catch {
            fatalError("Failed to fetch: \(error)")
        }
    }
    
    
    
    @IBAction func saveAction(sender: UIBarButtonItem) {
        
        saveLocation(tempLocation)
        
    }
    
    
    @IBAction func loadAction(sender: UIBarButtonItem) {
        
        // TODO: would be nice to show current location & saved location @ the same time
        // this would need a region instead of just coordinates
        let (lat, long) = loadLocation()
        updatePinAndMap(lat, longitude: long)
        
    }

    
    @IBAction func refreshAction(sender: UIBarButtonItem) {
        
        refreshLocation()
        
    }
}

