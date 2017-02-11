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
import Firebase

@objc class CampusLiveAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(lat: CLLocationDegrees, long: CLLocationDegrees, title: String? = nil, subtitle: String? = nil) {
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.title = title
        self.subtitle = subtitle
    }
}

class LiveViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    var location: CLLocation!
    var addEventLocation: CLLocation!// = CLLocation(latitude: 27.8812, longitude: -123.2374)
    let locationManager = CLLocationManager()
    //Change value to false
    var isOrgLogin: Bool = false
    
    @IBOutlet weak var addEventButton: UIButton!
    @IBOutlet weak var subtractEventButton: UIButton!
    
    @IBOutlet weak var showAllSwitch: UISwitch!
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var eventPin: UIImageView!
    @IBOutlet weak var eventDescriptive: UIButton!
    @IBOutlet weak var userSegment: UISegmentedControl!
    
    @IBOutlet weak var orgSegment: UISegmentedControl!
    let eventRef = FIRDatabase.database().reference().child("event")
    
    

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
        displayLiveEvents()
    }
    
    func displayLiveEvents(){
        //var episode:Episode? = nil
        eventRef.observe(.value, with: {(snap) in
            if let userDict = snap.value as? [String:AnyObject]{
                
                print(userDict)
                for each in userDict as [String: AnyObject] {
                    let autoID = each.key
                    var name = each.value["name"] as! String
                    var endDate = each.value["endDate"] as! String
                    var venue = each.value["venue"] as! String
                    var latitude = each.value["latitude"] as! NSNumber
                    var longitude = each.value["longitude"] as! NSNumber
                    var description = each.value["description"] as! String
                    let annotation = MKPointAnnotation()
                    annotation.title = name
                    annotation.subtitle = venue
                    annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
                    self.mapView.addAnnotation(annotation)
                }
            }
        })
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
            destinationViewController.location = location
            //destinationViewController.isOrgLogin = true
        }
    }
    /*
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        /*
        guard !annotation.isKind(of: MKUserLocation()) else {
            return nil
        }*/
        /*if annotation.isKindOfClass(MKUserLocation){
         //emty return, guard wasn't cooperating
         }else{
         return nil
         }*/
        
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView: MKAnnotationView?
        
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView = av
            annotationView?.isEnabled = true
        }
        
        if let annotationView = annotationView {
            // Configure your annotation view here
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "mapPins")
            let btn = UIButton()
            btn.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
            btn.setImage(UIImage(named: "info"), for: UIControlState())
            annotationView.rightCalloutAccessoryView = btn
            
        }
        return annotationView
    }*/
}
