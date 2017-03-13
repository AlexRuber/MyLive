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
import SVProgressHUD

@objc class CampusLiveAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var imageUrl: String!
    var eventDescription: String?
    var eventID: String?
    var endDate: String?
    var startDate: String?
    
    init(lat: CLLocationDegrees, long: CLLocationDegrees, title: String? = nil, subtitle: String? = nil, imageUrl: String!, eventDescription: String? = nil, eventID: String? = nil, endDate: String? = nil, startDate: String? = nil) {
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.title = title
        self.subtitle = subtitle
        self.imageUrl = imageUrl
        self.eventDescription = eventDescription
        self.eventID = eventID
        self.endDate = endDate
        self.startDate = startDate
        super.init()
    }
}

class LiveViewController: UIViewController, CLLocationManagerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    var location: CLLocation!
    var addEventLocation: CLLocationCoordinate2D!// = CLLocation(latitude: 27.8812, longitude: -123.2374)
    let locationManager = CLLocationManager()
    //Change value to false
    var isOrgLogin: Bool = false
    var uid: String?
    
    @IBOutlet weak var addEventButton: UIButton!
    @IBOutlet weak var subtractEventButton: UIButton!
    
    @IBOutlet weak var eventDescriptive: UIButton!
    @IBOutlet weak var orgSegment: UISegmentedControl!
    @IBOutlet weak var showAllSwitch: UISwitch!
    @IBOutlet weak var eventPin: UIImageView!
    
    
    //@IBOutlet weak var eventDescriptive: UIButton!
    //@IBOutlet weak var userSegment: UISegmentedControl!
    
    //@IBOutlet weak var orgSegment: UISegmentedControl!
    var eventRef = FIRDatabase.database().reference()//.child("event")
    var eventRefOrg = FIRDatabase.database().reference()
    var users = FIRDatabase.database().reference()
    
    @IBAction func refreshLocationButton(_ sender: Any) {
        locationManager.requestLocation()
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
        mapView!.setRegion(region, animated: true)
        mapView!.setCenter(mapView!.userLocation.coordinate, animated: true)
    }
    
    //Hides pins after posting event
    override func viewDidAppear(_ animated: Bool) {
        eventPin.isHidden = true
        eventDescriptive.isHidden = true
        addEventButton.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show(withStatus: "Loading Map :)")
        //Minus Button is hidden to start
        subtractEventButton.isHidden = true
        
        eventDescriptive.isHidden = true
        eventPin.isHidden = true
        
        //eventRef = eventRef.child("stu_events")
        
        if(isOrgLogin){
            
            //currentLocationButton.isHidden = true
            //addEventButton.isHidden = false
            //orgSegment.isHidden = false
            //userSegment.isHidden = true
        }else{
            
            //currentLocationButton.isHidden = false
            //addEventButton.isHidden = true
            //userSegment.isHidden = false
            //orgSegment.isHidden = true
        }
        
        let span = MKCoordinateSpanMake(0.018, 0.018)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 32.880777, longitude: -117.236395), span: span)
        
        mapView.setRegion(region, animated: true)
        
        isAuthorizedtoGetUserLocation()
        
        if CLLocationManager.locationServicesEnabled(){
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestLocation()
        }
        
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
        
        self.locationManager.delegate = self
        
        self.eventRefOrg = eventRefOrg.child("org_events")
        self.eventRef = eventRef.child("stu_events")
        
        self.uid = FIRAuth.auth()?.currentUser?.uid
        
        users = users.child("users").child(uid!)
        
        //displayOrgEvents()
        displayLiveEvents()
    }
    
    //if we have no permission to access user location, then ask user for permission.
    func isAuthorizedtoGetUserLocation() {
        
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse     {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    
    func displayLiveEvents(){
        eventRef.observe(.value, with: {(snap) in
            if let userDict = snap.value as? [String:AnyObject] {
                
                // print(userDict)
                for each in userDict as [String: AnyObject] {
                    
                    let autoID = each.key
                    let name = each.value["name"] as! String
                    
                    var endDateSubstring = each.value["endDate"] as! String
                    //let index = endDate.index(endDate.startIndex, offsetBy: 20)
                    //let endDateSubstring = endDate.substring(to: index)
                    
                    // for subtitle
                    let startDateSubstring = each.value["startDate"] as! String
                    //let indexStart = startDate.index(startDate.startIndex, offsetBy: 20)
                    //let startDateSubstring = startDate.substring(to: indexStart)
                    
                    let dateFormatter = DateFormatter()
                    
                    dateFormatter.locale = NSLocale.current
                    
                    let dateAsString = startDateSubstring
                    dateFormatter.dateFormat = "yyyy-MM-dd h:mm a"
                    let newDate = dateFormatter.date(from: dateAsString)
                    
                    print(newDate)
                    
                    let formatter: DateFormatter = DateFormatter()
                    formatter.dateFormat = "E hh:mm a"
                    let stringDate: String! = formatter.string(from: newDate!)
                    print("MAXXXXXX : \(stringDate)")
                    
                    let venue = each.value["venue"] as! String
                    let subtitle = "\(venue)" + ", " + "\(stringDate!)"
                    let latitude = each.value["latitude"] as! NSNumber
                    let longitude = each.value["longitude"] as! NSNumber
                    let description = each.value["description"] as! String
                    let imageUrl = each.value["profileImage"] as! String
                    let clAnnotation = CampusLiveAnnotation(lat: CLLocationDegrees(latitude), long: CLLocationDegrees(longitude), title: name, subtitle: subtitle, imageUrl: imageUrl, eventDescription: description, eventID: autoID, endDate: endDateSubstring, startDate: startDateSubstring)
                    
                    self.mapView.addAnnotation(clAnnotation)
                    
                    //add animation when pin gets posted
                }
            }
        })
    }
    
    /*
    func displayOrgEvents(){
        
        //self.eventRef = eventRef.child("stu_events")
        print("Inside Display Org Events.")
        
        eventRefOrg.observe(.value, with: {(snap) in
            if let userDict = snap.value as? [String:AnyObject] {
                
                // print(userDict)
                for each in userDict as [String: AnyObject] {
                    
                    let autoID = each.key
                    let name = each.value["name"] as! String
                    
                    var endDateSubstring = each.value["endDate"] as! String
                    //let index = endDate.index(endDate.startIndex, offsetBy: 20)
                    //let endDateSubstring = endDate.substring(to: index)
                    
                    // for subtitle
                    let startDateSubstring = each.value["startDate"] as! String
                    //let indexStart = startDate.index(startDate.startIndex, offsetBy: 20)
                    //let startDateSubstring = startDate.substring(to: indexStart)
                    
                    let dateFormatter = DateFormatter()
                    
                    dateFormatter.locale = NSLocale.current
                    
                    let dateAsString = startDateSubstring
                    dateFormatter.dateFormat = "yyyy-MM-dd h:mm a"
                    let newDate = dateFormatter.date(from: dateAsString)
                    
                    print(newDate)
                    
                    let formatter: DateFormatter = DateFormatter()
                    formatter.dateFormat = "E hh:mm a"
                    let stringDate: String! = formatter.string(from: newDate!)
                    print("\(stringDate)")
                    
                    let venue = each.value["venue"] as! String
                    let subtitle = "\(venue)" + ", " + "\(stringDate!)"
                    let latitude = each.value["latitude"] as! NSNumber
                    let longitude = each.value["longitude"] as! NSNumber
                    let description = each.value["description"] as! String
                    let imageUrl = each.value["profileImage"] as! String
                    let clAnnotation = CampusLiveAnnotation(lat: CLLocationDegrees(latitude), long: CLLocationDegrees(longitude), title: name, subtitle: subtitle, imageUrl: imageUrl, eventDescription: description, eventID: autoID, endDate: endDateSubstring, startDate: startDateSubstring)
                    
                    self.mapView.addAnnotation(clAnnotation)
                    
                    //add animation when pin gets posted
                }
            }
        })
    }
    */
    
    @IBAction func settingsClicked(_ sender: Any) {
        
    }
    
    func infoButtonTapped() {
        performSegue(withIdentifier: "detailEventVC", sender: self)
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
    
    //this method will be called each time when a user change his location access preference.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            print("User allowed us to access location")
            //do whatever init activities here.
        }
    }
    
    //this method is called by the framework on locationManager.requestLocation();
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //let location:CLLocation = locations.first!
        let location = locations.last
        
        let centerCoordinate = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        
        self.mapView.centerCoordinate = (location?.coordinate)!
        let reg = MKCoordinateRegionMakeWithDistance((location?.coordinate)!, 1500, 1500)
        
        self.mapView.setRegion(reg, animated: true)
        self.locationManager.stopUpdatingLocation()
        //self.addEventLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Errors: " + error.localizedDescription)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "AddEventDescription") {
            
            let nav = segue.destination as! UINavigationController
            let destinationViewController = nav.viewControllers[0] as! AddEventViewController
            destinationViewController.location = addEventLocation
            destinationViewController.isOrgLogin = self.isOrgLogin
            //destinationViewController.isOrgLogin = true
            
        }
        
        if (segue.identifier == "EventInfo") {
            let nav = segue.destination as! UINavigationController
            let destinationViewController = nav.viewControllers[0] as! EventInfoViewController
            
            let annotation: CampusLiveAnnotation = sender as! CampusLiveAnnotation
            
            destinationViewController.titleEvent = annotation.title
            destinationViewController.subtitleEvent = annotation.subtitle
            destinationViewController.imageEventUrl = annotation.imageUrl
            destinationViewController.descriptionEvent = annotation.eventDescription
            destinationViewController.startDateStr = annotation.startDate
            print(annotation.startDate)
            destinationViewController.endDateStr = annotation.endDate
            print(annotation.endDate)
        }
    }
    
}


extension LiveViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        
        if let annotation = annotation as? CampusLiveAnnotation {
            let identifier = "AnnotationIdentifier"
            //Custom view for pin annotation connected to FB Profile Pic
            /**
             var pinView: MKAnnotationView? = (mapView.dequeueReusableAnnotationView(withIdentifier: "CustomPinAnnotationView") as? MKAnnotationView)
             pinView = MKAnnotationView(annotation, reuseIdentifier: "CustomPinAnnotationView")
             pinView?.canShowCallout = true
             pinView?.image = UIImage(named: "icon-map-placemark-68x80")
             pinView?.calloutOffset = CGPoint(x: CGFloat(0), y: CGFloat(-5))
             var profileImageView = UIImageView()
             profileImageView.frame = CGRect(x: CGFloat(6), y: CGFloat(7), width: CGFloat(55), height: CGFloat(55))
             profileImageView.layer.masksToBounds = true
             profileImageView.layer.cornerRadius = 27
             profileImageView.setImageWith(URL(string: "http://domain.com/avatar.jpg"))
             pinView?.addSubview(profileImageView)
             */
            
            var view: MKAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier){ // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                // 3
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                
                let imageUrl: URL = NSURL(string: annotation.imageUrl) as! URL
                
                let data = try? Data(contentsOf: imageUrl)
                let profileImage : UIImage = UIImage(data: data!)!
                let eventUserImage : UIImageView = UIImageView(image: profileImage)
                //view.image = eventUserImage.image
                
                eventUserImage.layer.borderWidth = 1
                let white = UIColor(red: 255.0, green: 255.0, blue: 255.0, alpha: 1.0)
                eventUserImage.layer.borderColor = white.cgColor
                let f = CGRect(x: 1, y: 1, width: 40, height: 40) // CGRect(2,2,46,43)
                eventUserImage.frame = f
                eventUserImage.layer.cornerRadius = 22.0
                eventUserImage.layer.masksToBounds = true
                
                view.addSubview(eventUserImage)
                
                let dateFormatter = DateFormatter()
                
                dateFormatter.locale = NSLocale.current
                
                let dateAsString = annotation.endDate
                print(dateAsString!)
                dateFormatter.dateFormat = "yyyy-MM-dd h:mm a"
                let newDate = dateFormatter.date(from: dateAsString!)
                
                print(newDate)
                
                // using current date and time as an example
                let someDate = Date()
                
                // convert Date to TimeInterval (typealias for Doub
                let timeInterval = someDate.timeIntervalSince1970
                let integerDate = newDate?.timeIntervalSince1970
                
                let formatter: DateFormatter = DateFormatter()
                formatter.dateFormat = "E HH:mm"
                //let stringDate: String = formatter.string(from: newDate!)
                
                print("CURRENT DATE: \(timeInterval)")
                print("EVENT END DATE: \(integerDate)")
                print(dateAsString)
                if (integerDate! < timeInterval) {
                    
                    eventRef.child(annotation.eventID!).removeValue { (error, ref) in
                        print("DELETEEEEEEEEEE")
                        if error != nil {
                            print("error \(error)")
                        }
                    }
                }
                
                view.image = UIImage(named: "whiteCircularPin")
                
                users.observe(.value, with: {(snap) in
                    if let userDict = snap.value as? [String: AnyObject] {
                        
                        for each in userDict as [String: AnyObject] {
                            if each.key as! String == annotation.eventID {
                                view.image = UIImage(named: "blueCircularPin")
                                break
                            }
                        }
                    }
                })
                
                view.isEnabled = true
                view.canShowCallout = true
                //view.leftCalloutAccessoryView = UIImageView(image: pikeImage)
                view.leftCalloutAccessoryView = UIImageView(image: eventUserImage.image)
                
                //Custom Left Callout Image Settings
                view.leftCalloutAccessoryView?.contentMode = .scaleAspectFit
                view.leftCalloutAccessoryView?.frame = CGRect(x: CGFloat(5), y: CGFloat(5), width: CGFloat(eventPin.frame.size.height - 15), height: eventPin.frame.size.height - 15)
                view.leftCalloutAccessoryView?.layer.cornerRadius = (view.leftCalloutAccessoryView?.frame.width)!/2
                view.leftCalloutAccessoryView?.clipsToBounds = true
                
                
                let btn2 = UIButton()
                btn2.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                btn2.setImage(UIImage(named: "info"), for: UIControlState())
                view.rightCalloutAccessoryView = btn2
                // btn2.addTarget(self, action: "infoButtonTapped", for: .touchUpInside)
                
            }
            return view
        }
        return nil
    }
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        // geoCode(location)
        UIView.animate(withDuration: 0.4, animations: {
            self.eventDescriptive.layer.opacity = 1
            
            self.addEventLocation = self.location.coordinate
        })
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        UIView.animate(withDuration: 0.4, animations: {
            self.eventDescriptive.layer.opacity = 0
        })
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.leftCalloutAccessoryView{
            print("Left callout Accessory Called")
            mapView.deselectAnnotation(view.annotation, animated: false)
            performSegue(withIdentifier: "toProfileSegue", sender: view)
        }
        
        if control == view.rightCalloutAccessoryView {
            
            if let annotation = view.annotation as? CampusLiveAnnotation {
                performSegue(withIdentifier: "EventInfo", sender: annotation)
            }
            
            eventPin.isHidden = true
            subtractEventButton.isHidden = true
            addEventButton.isHidden = false
            eventDescriptive.isHidden = true
            print("Right callout Accessory  View Called")
            
        }
    }
    
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
       // SVProgressHUD.show(withStatus: "Loading Map :)")
        
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        SVProgressHUD.dismiss(withDelay: 0.8)
        
    }
    
}
