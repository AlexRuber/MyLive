//
//  LiveViewController.swift
//  CampusLive
//
//  Created by Raghav Nyati on 1/23/17.
//  Copyright © 2017 Mihai Ruber. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class LiveViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    var location: CLLocation!
    var addEventLocation: CLLocation!
    let locationManager = CLLocationManager()
    //Change value to false
    var isOrgLogin: Bool = false
    
    @IBOutlet weak var addEventButton: UIButton!
    @IBOutlet weak var subtractEventButton: UIButton!
    
    @IBOutlet weak var showAllSwitch: UISwitch!
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var eventPin: UIImageView!
    
    @IBOutlet weak var orgSegment: UISegmentedControl!
    @IBOutlet weak var userSegment: UISegmentedControl!
    @IBOutlet weak var eventDescriptive: UIButton!
    
    

    @IBAction func refreshLocationButton(_ sender: Any) {
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
        mapView!.setRegion(region, animated: true)
        mapView!.setCenter(mapView!.userLocation.coordinate, animated: true)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Minus Button is hidden to start
        subtractEventButton.isHidden = true
        
        //print(isOrgLogin ?? "")
        showAllSwitch.isHidden = false
        
        eventDescriptive.isHidden = true
        eventPin.isHidden = true
        
        if(isOrgLogin){
            //currentLocationButton.isHidden = true
            addEventButton.isHidden = false
            orgSegment.isHidden = false
            userSegment.isHidden = true
        }else{
            //currentLocationButton.isHidden = false
            addEventButton.isHidden = true
            userSegment.isHidden = false
            orgSegment.isHidden = true
        }
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        
        //var gesture = UIPanGestureRecognizer(target: self, action: Selector("userDragged:"))
        //addEventButton.addGestureRecognizer(gesture)
        
    }
    
    //Event Button Click Variations
    
    @IBAction func addEventButtonClicked(_ sender: Any) {
        print("add event button clicked.")
        eventDescriptive.isHidden = false
        eventPin.isHidden = false
        addEventButton.isHidden = true
        subtractEventButton.isHidden = false
    }
    
    @IBAction func subtractEventButtonClicked(_ sender: Any) {
        eventPin.isHidden = true
        eventDescriptive.isHidden = true
        addEventButton.isHidden = false
        subtractEventButton.isHidden = true
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
// MARK: - Location Delegate Methods 
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.location = locations.last! as CLLocation


        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Errors: " + error.localizedDescription)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "AddEventDescription"){
            let nav = segue.destination as! UINavigationController
            let destinationViewController = nav.viewControllers[0] as! AddEventViewController
            destinationViewController.location = addEventLocation
            //destinationViewController.isOrgLogin = true
        }
    }
    
    

    
     //Fade out for Event Specific Button
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        self.location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
        UIView.animate(withDuration: 0.4, animations: {
            
            self.eventDescriptive.layer.opacity = 1
            
        })
    }
    
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        UIView.animate(withDuration: 0.4, animations: {
            self.eventDescriptive.layer.opacity = 0
        })
    }
    
}
