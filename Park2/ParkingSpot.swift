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
    
    
    func isSaved() -> Bool {
        
        return (coords.longitude != 0)
        
    }
    
    
    // MARK: Types
    
    struct PropertyKey {
        static let latitudeKey = "latitude"
        static let longitudeKey = "longitude"
        static let reminderKey = "reminder"
    }

    
    // MARK: NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(coords.latitude, forKey: PropertyKey.latitudeKey)
        aCoder.encodeObject(coords.longitude, forKey: PropertyKey.longitudeKey)
        aCoder.encodeObject(reminder, forKey: PropertyKey.reminderKey)
        
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        let lat = aDecoder.decodeObjectForKey(PropertyKey.latitudeKey) as! CLLocationDegrees
        let long = aDecoder.decodeObjectForKey(PropertyKey.longitudeKey) as! CLLocationDegrees
        let reminder = aDecoder.decodeObjectForKey(PropertyKey.reminderKey) as! NSDate
        let coords = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        self.init(coords: coords, reminder: reminder)
    
    }
    
    
    

    
}

