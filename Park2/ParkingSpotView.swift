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
        dropPin = nil

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
    
    
    func savePin(location: CLLocationCoordinate2D) {
        
        dropPin = MKPointAnnotation()
        dropPin?.coordinate = location
    }
    
    
}
