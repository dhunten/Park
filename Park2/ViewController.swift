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
    var manager: CLLocationManager!
    var userLocation = CLLocationCoordinate2D()
    let dateFormatter = NSDateFormatter()
    let timeFormatter = NSDateFormatter()
    let notification = UILocalNotification()
    var dropPin: MKPointAnnotation? = nil


    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Notifications setup
        reminderDatePicker.minimumDate = NSDate(timeIntervalSinceNow: 0)
        dateFormatter.dateStyle = .FullStyle
        dateFormatter.timeStyle = .NoStyle
        timeFormatter.dateStyle = .NoStyle
        timeFormatter.timeStyle = .ShortStyle
        notification.alertBody = "Move your car!"
        notification.alertAction = "See your car's location"
        notification.category = "CAR_CATEGORY"

        // Location manager setup
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 25 //meters
        manager.requestWhenInUseAuthorization()
        
        // Other
        mapView.delegate = self
        loadFromFile()
        manager.requestLocation()
        
        if parkingSpot.isSaved() {
            mainActionButton.title = "Forget"
        }
    }
    
    
    

    
    @IBAction func saveAction(sender: UIBarButtonItem) {
        
        // Is there a parking spot saved already?
        if parkingSpot.isSaved()  {
            
            // Forget parking spot
            mapView.removeAnnotation(dropPin!)
            dropPin = nil
            mainActionButton.title = "Remember"
            parkingSpot.coords = CLLocationCoordinate2D(latitude: 0, longitude: 0)
            reminderDatePicker.minimumDate = NSDate(timeIntervalSinceNow: 0)
            
        } else {
            
            // Remember new parking spot
            parkingSpot.reminder = reminderDatePicker.date
            mainActionButton.title = "Forget"
            dropPin?.coordinate = userLocation
            parkingSpot.coords = userLocation
            setNotification(parkingSpot.reminder)
            
        }
        
        updateMapView()
        saveToFile()

    }
    

    
    @IBAction func refreshAction(sender: UIBarButtonItem) {
        
        manager.requestLocation()
        
    }
    

    
    // MARK: Location manager
    // When GPS data is returned
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        userLocation = locations[0].coordinate
        updateMapView()

    }

    
    // Error getting GPS
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print(error)
        
    }
    
    
    
    // Update UI
    func updateMapView() {
        
        if parkingSpot.isSaved() {
            
            // Set date picker to reminder time
            reminderDatePicker.date = parkingSpot.reminder
            
            // Update pin
            if let pin = dropPin, _ = mapView.viewForAnnotation(pin) {
                
            } else {
                
                // Add if pin doesn't exist
                let dateString = dateFormatter.stringFromDate(parkingSpot.reminder)
                let timeString = timeFormatter.stringFromDate(parkingSpot.reminder)
                dropPin = MKPointAnnotation()
                dropPin?.coordinate = parkingSpot.coords
                dropPin?.title = dateString
                dropPin?.subtitle = timeString
                mapView.addAnnotation(dropPin!)
            }
            
            // Zoom map to correct bounds
            let p1 = MKMapPointForCoordinate(userLocation)
            let p2 = MKMapPointForCoordinate(parkingSpot.coords)
            let mapRect = MKMapRectMake(fmin(p1.x,p2.x), fmin(p1.y,p2.y), fabs(p1.x-p2.x), fabs(p1.y-p2.y)) // bc the MapRect only expands to the right & up
            mapView.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
            
        } else {
            
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(userLocation, 20.0,  20.0)
            mapView.setRegion(coordinateRegion, animated: true)
            
        }
        
    }
    
    
    // Delegate protocol method for annotation
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKPointAnnotation {
            
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
            
            pinAnnotationView.draggable = true
            pinAnnotationView.canShowCallout = true
            pinAnnotationView.animatesDrop = true
            
            return pinAnnotationView
        }
        
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        
        if newState == .Ending {
            
            parkingSpot.coords = view.annotation!.coordinate
            saveToFile()
            
        }
        
    }
    
    
    // MARK: Persistent storage
    func loadFromFile() {

        if let ps = NSKeyedUnarchiver.unarchiveObjectWithFile(ParkingSpot.ArchiveURL.path!) as? ParkingSpot {
            
            parkingSpot = ps
            print("Loaded", parkingSpot.coords)
            
        }

    }
    
    
    func saveToFile() {
        
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(parkingSpot, toFile: ParkingSpot.ArchiveURL.path!)
        if isSuccessfulSave {
            
            print("Saved!", parkingSpot.coords)
            
        }
        
    }
    
    
    
    // MARK: Notification management
    func setNotification(reminder: NSDate) {
        
        // create a local notification
        notification.fireDate = reminder
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        print("Reminder date: ", reminder.description)
        
    }
    
    
    func cancelNotificaion() {
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
    }
    
    
}


