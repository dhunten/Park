//
//  LocationItem.swift
//  Park2
//
//  Created by Derek Hunten on 9/17/15.
//  Copyright © 2015 BLOOF INDUSTRIES. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import CoreData


class ParkingSpot {
    
    var coords: CLLocationCoordinate2D
    var reminder: NSDate
    var moc: NSManagedObjectContext
    
    
    init(coords: CLLocationCoordinate2D, reminder: NSDate) {
        
        self.coords = coords
        self.reminder = reminder
        moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
    }
    
    
    // Mainly for testing
    convenience init() {
        
        self.init(coords: CLLocationCoordinate2DMake(0, 0), reminder: NSDate(timeIntervalSinceNow: 15))
        
    }
    
    
    
    func isPastDue() -> Bool {
        
        return (NSDate().compare(self.reminder) == NSComparisonResult.OrderedDescending)
        
    }
    

    // Save a location to core data
    func saveLocation(location: CLLocationCoordinate2D) {
        
        // Set the parking spot coordinates to the new one
        coords = location
        
        // Setup the entry we're inserting into core data
        let entity = NSEntityDescription.entityForName("Car", inManagedObjectContext: moc)
        let carManagedObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: moc)
        
        // Add the data into the entry
        carManagedObject.setValue(coords.latitude, forKey: "lat")
        carManagedObject.setValue(coords.longitude, forKey: "long")
        
        print("Attempting to save lat: \(coords.latitude), long: \(coords.longitude)")
        
        do {
            // Save the entry into core data
            // TODO: just keep one instance of Car, currently it just keeps appending more to core data
            try moc.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    
    // Load data from core data
    func loadLocation() {
        
        let locationsFetch = NSFetchRequest(entityName: "Car")
        
        do {
            let fetchedLocation = try moc.executeFetchRequest(locationsFetch)
            
            if let fetchedLong = fetchedLocation.last?.valueForKey("long") as? Double, fetchedLat = fetchedLocation.last?.valueForKey("lat") as? Double {
                
                print("Loading Lat: \(fetchedLat), Long: \(fetchedLong)")
                coords = CLLocationCoordinate2DMake(fetchedLat, fetchedLong)
                
            }
            
        } catch {
            fatalError("Failed to fetch: \(error)")
        }
    }
    
}