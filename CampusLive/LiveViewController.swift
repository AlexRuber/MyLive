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
    @IBOutlet weak var showAllSwitch: UISwitch!
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var eventPin: UIImageView!
    @IBOutlet weak var eventDescription: UIButton!
    
    @IBAction func addEventDescription(_ sender: Any) {
        performSegue(withIdentifier: "AddEventDescription", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(isOrgLogin ?? "")
        showAllSwitch.isHidden = false
        
        eventDescription.isHidden = true
        eventPin.isHidden = true
        
        if(isOrgLogin){
            //currentLocationButton.isHidden = true
            addEventButton.isHidden = false
        }else{
            //currentLocationButton.isHidden = false
            addEventButton.isHidden = true
        }
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        
        //var gesture = UIPanGestureRecognizer(target: self, action: Selector("userDragged:"))
        //addEventButton.addGestureRecognizer(gesture)
        
    }
    
    @IBAction func addEventButtonClicked(_ sender: Any) {
        print("add event button clicked.")
        eventDescription.isHidden = false
        eventPin.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
// MARK: - Location Delegate Methods 
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
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
            let destinationViewController = segue.destination as! AddEventViewController
            destinationViewController.location = addEventLocation
            // destinationViewController.isOrgLogin = true
        }
    }
}
