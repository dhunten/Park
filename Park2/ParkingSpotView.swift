//
//  ParkingSpotView.swift
//  Park2
//
//  Created by Derek Hunten on 9/18/15.
//  Copyright © 2015 BLOOF INDUSTRIES. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ParkingSpotView: NSObject, CLLocationManagerDelegate {

    // Here we should
    // • Schedule Notifications
    // • Map interactions
    // • Location interactionw

    let notification: UILocalNotification
    let dropPin: MKPointAnnotation
    

    override init() {

        notification = UILocalNotification()
        dropPin = MKPointAnnotation()

        super.init()

        
    }
    
    
    func setReminder(reminder: NSDate) {
        
        // create a local notification
        notification.alertBody = "Move your car!"
        notification.alertAction = "see your car's location"
        notification.fireDate = reminder
        notification.category = "CAR_CATEGORY"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
    }
    
    
    

    
    
    // Wrap location manager request
    func refreshLocation() {
        
//        manager.requestLocation()
        
    }
    
    
}
