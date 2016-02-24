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
    @IBOutlet weak var timeRemainingLabel: UILabel!
    var parkingSpot = ParkingSpot()
    var manager: CLLocationManager!
    var userLocation = CLLocationCoordinate2D()
    let dateFormatter = NSDateFormatter()
    let timeFormatter = NSDateFormatter()
    let timeRemainderFormatter = NSDateComponentsFormatter()
    let notification = UILocalNotification()
    var dropPin: MKPointAnnotation? = nil


    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Notifications setup
        reminderDatePicker.minimumDate = NSDate()
        dateFormatter.dateStyle = .FullStyle
        dateFormatter.timeStyle = .NoStyle
        timeFormatter.dateStyle = .NoStyle
        timeFormatter.timeStyle = .ShortStyle
        notification.alertBody = "Move your car!"
        notification.alertAction = "See your car's location"
        notification.category = "CAR_CATEGORY"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.applicationIconBadgeNumber = 1
        
        // Time remaining label formatter
        timeRemainderFormatter.includesTimeRemainingPhrase = true
        timeRemainderFormatter.unitsStyle = .Abbreviated
        timeRemainderFormatter.allowedUnits = [.Day, .Hour, .Minute]
        let _ = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "updateTimeView", userInfo: nil, repeats: true)

        // Location manager setup
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
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
            reminderDatePicker.minimumDate = NSDate(timeIntervalSinceNow: 360)
            
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
        manager.requestLocation()

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
            
            // Set date picker to reminder time & Update and display time remaining
            updateTimeView()
            
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
            
            updateTimeView()
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(userLocation, 20.0,  20.0)
            mapView.setRegion(coordinateRegion, animated: true)
            
        }
        
    }
    
    
    func updateTimeView() {
        
        if parkingSpot.isSaved() {
            
            let remainingTimeForSpot = parkingSpot.reminder.timeIntervalSinceDate(NSDate())
            var remainingTimeStringForLabel = String?()
            
            if remainingTimeForSpot < 0 {
                
                remainingTimeStringForLabel = "Time's up!"
                
            } else {
                
                remainingTimeStringForLabel = timeRemainderFormatter.stringFromTimeInterval(remainingTimeForSpot)
                
            }
            
            timeRemainingLabel.text = remainingTimeStringForLabel
            timeRemainingLabel.hidden = false
            reminderDatePicker.hidden = true
            
        } else {
            
            timeRemainingLabel.hidden = true
            reminderDatePicker.hidden = false
            
        }
        
    }
    
    
    // Delegate protocol method for annotation
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKPointAnnotation {
            
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
            annotationView.draggable = true
            annotationView.canShowCallout = true
            //pinAnnotationView.animatesDrop = true
            annotationView.image = UIImage(named: "Car") // 40 x 60
            annotationView.centerOffset = CGPoint(x: 0, y: -26)
            return annotationView
            
        }
        
        return nil
    }
    

    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        
        if newState == .Ending {
            
            parkingSpot.coords = view.annotation!.coordinate
            saveToFile()
            view.dragState = .None
            
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


