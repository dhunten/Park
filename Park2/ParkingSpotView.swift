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

class ParkingSpotView: NSObject {


    let notification: UILocalNotification
    var dropPin: MKPointAnnotation?
    

    override init() {

        notification = UILocalNotification()
        notification.alertBody = "Move your car!"
        notification.alertAction = "See your car's location"
        notification.category = "CAR_CATEGORY"
        dropPin = nil

        super.init()
        
    }
    
    
    func setReminder(reminder: NSDate) {
        
        // create a local notification
        notification.fireDate = reminder
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        print("Reminder date: ", reminder.description)
        
    }
    
    func cancletReminder() {
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
    }
    
    
    func savePin(location: CLLocationCoordinate2D, title: String) {
        
        dropPin = MKPointAnnotation()
        dropPin?.coordinate = location
        dropPin?.title = title
        
    }
    
    
}
