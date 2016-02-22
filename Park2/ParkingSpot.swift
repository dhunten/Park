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


// Model?
class ParkingSpot: NSObject, NSCoding {
    
    var coords: CLLocationCoordinate2D
    var reminder: NSDate
    
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("park")
    
    
    init(coords: CLLocationCoordinate2D, reminder: NSDate) {
        
        self.coords = coords
        self.reminder = reminder
        
        // should possibly verify the variables are OK
        
        super.init()
        
    }
    
    
    // Mainly for testing
    convenience override init() {
        
        self.init(coords: CLLocationCoordinate2DMake(0, 0), reminder: NSDate(timeIntervalSinceNow: 15))
        
    }
    
    
    
    func isPastDue() -> Bool {
        
        return (NSDate().compare(self.reminder) == NSComparisonResult.OrderedDescending)
        
    }
    

    // Save a location vis NSCoding
    func saveLocation() {
        

        
    }
    
    
    // Load data
    func loadLocation() {
        

        
    }
    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(coords.latitude, forKey: "latitude")
        aCoder.encodeObject(coords.longitude, forKey: "longitude")
        aCoder.encodeObject(reminder, forKey: "reminder")
        
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        let lat = aDecoder.decodeObjectForKey("latitude") as! CLLocationDegrees
        let long = aDecoder.decodeObjectForKey("longitude") as! CLLocationDegrees
        let coords = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let reminder = aDecoder.decodeObjectForKey("reminder") as! NSDate
        
        self.init(coords: coords, reminder: reminder)
    
    }
    
}

