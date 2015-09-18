//
//  LocationItem.swift
//  Park2
//
//  Created by Derek Hunten on 9/17/15.
//  Copyright © 2015 BLOOF INDUSTRIES. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit



class ParkingSpot {
    
    var coords: CLLocation
    var reminder: NSDate
    let notification = UILocalNotification()
    
    
    init(coords: CLLocation, reminder: NSDate) {
        
        self.coords = coords
        self.reminder = reminder
        
    }
    
    
    init() {
        
        // Mainly for testing
        self.coords = CLLocation(latitude: 0, longitude: 0)
        self.reminder = NSDate(timeIntervalSinceNow: 15)
        
    }
    
    
    
    func isPastDue() -> Bool {
        
        return (NSDate().compare(self.reminder) == NSComparisonResult.OrderedDescending)
        
    }
    
    
    func setReminder() {
        
        // create a local notification
        notification.alertBody = "Move your car!"
        notification.alertAction = "see your car's location"
        notification.fireDate = self.reminder
        notification.category = "CAR_CATEGORY"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
    }
    
}