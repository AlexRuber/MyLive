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
    //var eventDescription: String?
    var eventID: String?
    var endDate: String?
    var startDate: String?
    var type: String?
    var colorType: String?
    
    init(lat: CLLocationDegrees, long: CLLocationDegrees, title: String? = nil, subtitle: String? = nil, imageUrl: String!, eventId: String!, endDate: String? = nil, startDate: String? = nil, type: String!, colorType: String!) {
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.title = title
        self.subtitle = subtitle
        self.imageUrl = imageUrl
        //self.eventDescription = eventDescription
        self.eventID = eventId
        self.endDate = endDate
        self.startDate = startDate
        self.type = type
        self.colorType = colorType
        super.init()
    }
}

class LiveViewController: UIViewController, CLLocationManagerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    var location: CLLocation!
    var addEventLocation: CLLocationCoordinate2D!
    let locationManager = CLLocationManager()
    
    
    var uid: String?
    
    @IBOutlet weak var verifiedButton: UIButton!
    
    @IBOutlet weak var eventDescriptive: UIButton!
    @IBOutlet weak var orgSegment: UISegmentedControl!
    @IBOutlet weak var showAllSwitch: UISwitch!
    @IBOutlet weak var eventPin: UIImageView!
    @IBOutlet weak var schoolButton: UIButton!
    
    //var eventOrgRef = FIRDatabase.database().reference()
    //var eventBusRef = FIRDatabase.database().reference()
    
    var eventRef: FIRDatabaseReference!
    
    @IBAction func refreshLocationButton(_ sender: Any) {
        locationManager.requestLocation()
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        self.mapView.setRegion(region, animated: true)
        mapView!.setRegion(region, animated: true)
        mapView!.setCenter(mapView!.userLocation.coordinate, animated: true)
        print("Did tap user location")
    }
    
 
    //this method is called by the framework on locationManager.requestLocation();
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations.last! as CLLocation
        
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
        
    }
    
    //Hides pins after posting event
    override func viewDidAppear(_ animated: Bool) {
        self.mapView.showsUserLocation = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        super.viewDidLoad()
        
        
        
        self.mapView.showsUserLocation = true
        
        
        
        orgSegment.tintColor = UIColor.white
        
        
        
        //print(AppState.sharedInstance.dafaultCampus)
        
        //print(AppState.sharedInstance.defaultLatitude)
        
        //print(AppState.sharedInstance.defaultLongitude)
        
        
        
        //Settings for the loading spinner
        
        let foregroundColor = UIColor(red: 27/255, green: 150/255, blue: 254/255, alpha: 1)
        
        let backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        
        SVProgressHUD.show()
        
        SVProgressHUD.setForegroundColor(foregroundColor)
        
        SVProgressHUD.setBackgroundColor(backgroundColor)
        
        //Minus Button is hidden to start
        
        //subtractEventButton.isHidden = true
        
        
        
        //eventDescriptive.isHidden = true
        
        //eventPin.isHidden = true
        
        
    
        isAuthorizedtoGetUserLocation()
        
        if CLLocationManager.locationServicesEnabled(){
            
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestLocation()
        }
        
    
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        self.mapView.delegate = self
        self.locationManager.delegate = self
        
        //self.eventBusRef = eventBusRef.child("business_events")
        
        //self.eventOrgRef = eventOrgRef.child("org_events")
        
        
        let span = MKCoordinateSpanMake(0.018, 0.018)
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: AppState.sharedInstance.defaultLatitude as! CLLocationDegrees, longitude: AppState.sharedInstance.defaultLongitude as! CLLocationDegrees), span: span)
        
        mapView.setRegion(region, animated: true)
        
        eventRef = FIRDatabase.database().reference().child("events")
        
        self.uid = FIRAuth.auth()?.currentUser?.uid
        
        
        
        isVerifiedFlag = true
        
        verifiedButton.setImage(UIImage(named: "OrgFilled"), for: UIControlState.normal)
        
        
        
        displayLiveEvents()
        
        //displayTrendingEvents()
        
    }
    
    
    
    //if we have no permission to access user location, then ask user for permission.
    func isAuthorizedtoGetUserLocation() {
        
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse     {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        displayRelevantEvents()
    }
    
    
    func displayLiveEvents() {

        MeasurementHelper.liveAnnotationClickEvent()
        let allAnnotations = self.mapView.annotations
        for annotation in allAnnotations {
            mapView.view(for: annotation)?.isHidden = true
        }
        if (AppState.sharedInstance.liveEventDict == nil){
            DispatchQueue.main.async {
                self.eventRef.observe(.value, with: {(snap) in
                    if let userDict = snap.value as? [String:AnyObject] {
                        if(AppState.sharedInstance.liveEventDict?.count != userDict.count){
                            AppState.sharedInstance.liveEventDict = userDict
                            self.showEvents(userDict: AppState.sharedInstance.liveEventDict!, str: "live")
                        }
                    }
                })
            }
        }else{
            print("records from global variable fetched")
            DispatchQueue.main.async {
                self.showEvents(userDict: AppState.sharedInstance.liveEventDict!, str: "live")
            }
        }
    }
    
    func showEvents(userDict: [String: AnyObject], str: String){
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd h:mm a"
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "E hh:mm a"
        
        for each in userDict as [String: AnyObject] {
            if(str == "live"){
                
                let autoID = each.key
                //let type = each.value["type"] as! String
                let name = each.value["title"] as! String
                let endDateSubstring = each.value["endDate"] as! String
                let startDateSubstring = each.value["startDate"] as! String
                let dateAsString = startDateSubstring
                let newDate = dateFormatter.date(from: dateAsString)
                let stringDate: String! = formatter.string(from: newDate!)
                let startDateTimeInterval = newDate?.timeIntervalSince1970
                let currentDateTimeInterval = currentDate.timeIntervalSince1970
                let dayFromNow = currentDateTimeInterval + 86400.0
                
                if (Double(startDateTimeInterval!) < dayFromNow) {
                    let venue = each.value["venue"] as! String
                    let subtitle = "\(venue)" + ", " + "\(stringDate!)"
                    let latitude = each.value["latitude"] as! NSNumber
                    let longitude = each.value["longitude"] as! NSNumber
                    //let description = each.value["description"] as! String
                    let imageUrl = each.value["image"] as! String
                    
                    let type = each.value["type"] as! String
                    let colorType = each.value["colorType"] as! String
                    
                    let clAnnotation = CampusLiveAnnotation(lat: CLLocationDegrees(latitude), long: CLLocationDegrees(longitude), title: name, subtitle: subtitle, imageUrl: imageUrl, eventId: autoID, endDate: endDateSubstring, startDate: startDateSubstring, type: type, colorType: colorType)
                    
                    self.mapView.addAnnotation(clAnnotation)
                    //self.mapView.addAnnotation(clAnnotation)
                }
            }else{
                let endDateSubstring = each.value["endDate"] as! String
                let startDateSubstring = each.value["startDate"] as! String
                let dateAsString = startDateSubstring
                let newDate = dateFormatter.date(from: dateAsString)
                let startDateTimeInterval = newDate?.timeIntervalSince1970
                let currentDateTimeInterval = currentDate.timeIntervalSince1970
                let dayFromNow = currentDateTimeInterval + 86400.0
                //let endDateFormat = dateFormatter.date(from: endDateSubstring)
                //let endDateTimeInterval = endDateFormat?.timeIntervalSince1970
                let trendingEventEndDate = currentDateTimeInterval + 691200
                if(Double(trendingEventEndDate) > Double(startDateTimeInterval!)){
                    if (Double(startDateTimeInterval!) > dayFromNow) {
                        let stringDate: String! = formatter.string(from: newDate!)
                        let autoID = each.key
                        let name = each.value["title"] as! String
                        let venue = each.value["venue"] as! String
                        let subtitle = "\(venue)" + ", " + "\(stringDate!)"
                        let latitude = each.value["latitude"] as! NSNumber
                        let longitude = each.value["longitude"] as! NSNumber
                        
                        let imageUrl = each.value["image"] as! String
                        let type = each.value["type"] as! String
                        let colorType = each.value["colorType"] as! String
                        
                        let clAnnotation = CampusLiveAnnotation(lat: CLLocationDegrees(latitude), long: CLLocationDegrees(longitude), title: name, subtitle: subtitle, imageUrl: imageUrl, eventId: autoID, endDate: endDateSubstring, startDate: startDateSubstring, type: type, colorType: colorType)
                        
                        self.mapView.addAnnotation(clAnnotation)
                    }
                }
            }
            
        }
    }
    /*
    func displayLiveOrgEvents(){
     
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd h:mm a"
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "E hh:mm a"
     
        let allAnnotations = self.mapView.annotations
        
        for annotation in allAnnotations {
            mapView.view(for: annotation)?.isHidden = true
        }
        
        eventRefOrg.observe(.value, with: {(snap) in
            if let userDict = snap.value as? [String:AnyObject] {
                for each in userDict as [String: AnyObject] {
                    let autoID = each.key
                    let name = each.value["name"] as! String
                    let endDateSubstring = each.value["endDate"] as! String
                    let startDateSubstring = each.value["startDate"] as! String
                    let dateAsString = startDateSubstring
                    let newDate = dateFormatter.date(from: dateAsString)
                    let stringDate: String! = formatter.string(from: newDate!)
                    let startDateTimeInterval = newDate?.timeIntervalSince1970
                    let currentDateTimeInterval = currentDate.timeIntervalSince1970
                    let dayFromNow = currentDateTimeInterval + 86400.0
                    
                    if (Double(startDateTimeInterval!) < dayFromNow) {
                        
                        let venue = each.value["venue"] as! String
                        let subtitle = "\(venue)" + ", " + "\(stringDate!)"
                        let latitude = each.value["latitude"] as! NSNumber
                        let longitude = each.value["longitude"] as! NSNumber
                        let description = each.value["description"] as! String
                        let imageUrl = each.value["profileImage"] as! String
                        let clAnnotation = CampusLiveAnnotation(lat: CLLocationDegrees(latitude), long: CLLocationDegrees(longitude), title: name, subtitle: subtitle, imageUrl: imageUrl, eventDescription: description, eventID: autoID, endDate: endDateSubstring, startDate: startDateSubstring)
                        
                        self.mapView.addAnnotation(clAnnotation)
                    }
                }
            }
        })
    }
    
    func displayOrgTrendingEvents(){
        
        let allAnnotations = self.mapView.annotations
        
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd h:mm a"
        
        let currentDateTimeInterval = currentDate.timeIntervalSince1970
        let dayFromNow = currentDateTimeInterval + 86400.0
        
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "E hh:mm a"
        
        for annotation in allAnnotations {
            mapView.view(for: annotation)?.isHidden = true
        }
        
        eventRefOrg.observe(.value, with: {(snap) in
            if let userDict = snap.value as? [String:AnyObject] {
                
                // print(userDict)
                for each in userDict as [String: AnyObject] {
                    
                    let endDateSubstring = each.value["endDate"] as! String
                    let startDateSubstring = each.value["startDate"] as! String
                    let dateAsString = startDateSubstring
                    let newDate = dateFormatter.date(from: dateAsString)
                    let startDateTimeInterval = newDate?.timeIntervalSince1970
                    
                    if (Double(startDateTimeInterval!) > dayFromNow) {
                        let stringDate: String! = formatter.string(from: newDate!)
                        let autoID = each.key
                        let name = each.value["name"] as! String
                        let venue = each.value["venue"] as! String
                        let subtitle = "\(venue)" + ", " + "\(stringDate!)"
                        let latitude = each.value["latitude"] as! NSNumber
                        let longitude = each.value["longitude"] as! NSNumber
                        let description = each.value["description"] as! String
                        let imageUrl = each.value["profileImage"] as! String
                        let clAnnotation = CampusLiveAnnotation(lat: CLLocationDegrees(latitude), long: CLLocationDegrees(longitude), title: name, subtitle: subtitle, imageUrl: imageUrl, eventDescription: description, eventID: autoID, endDate: endDateSubstring, startDate: startDateSubstring)
                        
                        self.mapView.addAnnotation(clAnnotation)
                    }
                }
            }
        })
    }*/
    
    func displayTrendingEvents() {
        
        MeasurementHelper.liveAnnotationClickEvent()

        let allAnnotations = self.mapView.annotations
        
        for annotation in allAnnotations {
            mapView.view(for: annotation)?.isHidden = true
        }
        
        if (AppState.sharedInstance.trendingEventDict == nil){
            
            DispatchQueue.main.async {
                self.eventRef.observe(.value, with: {(snap) in
                    if let userDict = snap.value as? [String:AnyObject] {
                        
                        if(AppState.sharedInstance.trendingEventDict?.count != userDict.count){
                            AppState.sharedInstance.trendingEventDict = userDict
                            self.showEvents(userDict: AppState.sharedInstance.trendingEventDict!, str: "trend")
                        }
                    }
                })
            }
        }else{
            print("records from global variable fetched")
            DispatchQueue.main.async {
                self.showEvents(userDict: AppState.sharedInstance.trendingEventDict!, str: "trend")
            }
        }
        
        /*
        MeasurementHelper.trendingSegmentEvent()
        
        self.mapView.showsUserLocation = true

        
        let allAnnotations = self.mapView.annotations
        
        for annotation in allAnnotations {
            mapView.view(for: annotation)?.isHidden = true
        }
        
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd h:mm a"
        
        let currentDateTimeInterval = currentDate.timeIntervalSince1970
        let dayFromNow = currentDateTimeInterval + 86400.0
        
        //691200
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "E hh:mm a"
        
        //displaying ORG events
        //displayOrgTrendingEvents()
        
        //displaying Student events
        eventRef.observe(.value, with: {(snap) in
            if let userDict = snap.value as? [String:AnyObject] {
                
                for each in userDict as [String: AnyObject] {
                    
                    let endDateSubstring = each.value["endDate"] as! String
                    let startDateSubstring = each.value["startDate"] as! String
                    let dateAsString = startDateSubstring
                    let newDate = dateFormatter.date(from: dateAsString)
                    let startDateTimeInterval = newDate?.timeIntervalSince1970
                    //let endDateFormat = dateFormatter.date(from: endDateSubstring)
                    //let endDateTimeInterval = endDateFormat?.timeIntervalSince1970
                    let trendingEventEndDate = currentDateTimeInterval + 691200
                    
                    if(Double(trendingEventEndDate) > Double(startDateTimeInterval!)){
                        if (Double(startDateTimeInterval!) > dayFromNow) {
                            let stringDate: String! = formatter.string(from: newDate!)
                            let autoID = each.key
                            let name = each.value["title"] as! String
                            let venue = each.value["venue"] as! String
                            let subtitle = "\(venue)" + ", " + "\(stringDate!)"
                            let latitude = each.value["latitude"] as! NSNumber
                            let longitude = each.value["longitude"] as! NSNumber
                            
                            let imageUrl = each.value["image"] as! String
                            let type = each.value["type"] as! String
                            let colorType = each.value["colorType"] as! String
                            
                            let clAnnotation = CampusLiveAnnotation(lat: CLLocationDegrees(latitude), long: CLLocationDegrees(longitude), title: name, subtitle: subtitle, imageUrl: imageUrl, eventId: autoID, endDate: endDateSubstring, startDate: startDateSubstring, type: type, colorType: colorType)
                            
                            self.mapView.addAnnotation(clAnnotation)
                        }
                    }
                }
            }
        })
        */
    }
    
    @IBAction func settingsClicked(_ sender: Any) {
        
    }
    
    var isVerifiedFlag = true
    
    func displayRelevantEvents(){
        switch orgSegment.selectedSegmentIndex {
        case 0:
            if(isVerifiedFlag){
                displayLiveEvents()
                self.mapView.showsUserLocation = true

            }else{
                
                self.mapView.showsUserLocation = true

                displayLiveEvents()
            }
        case 1:
            if(isVerifiedFlag){
                displayTrendingEvents()
                
                //displayOrgTrendingEvents()
            }else{
                displayTrendingEvents()
            }
        default:
            break
        }
    }
    
    @IBAction func isVerifiedClicked(_ sender: Any) {
        if(!isVerifiedFlag){
            isVerifiedFlag = true
            verifiedButton.setImage(UIImage(named: "OrgFilled"), for: UIControlState.normal)
            
            //Zoom in to UCSD School
            let schoolSpan = MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
            let schoolCoordinate = CLLocationCoordinate2DMake(32.88077651406362, -117.2365665435791)
            let schoolRegion = MKCoordinateRegionMake(schoolCoordinate, schoolSpan)
            self.mapView.setRegion(schoolRegion, animated: true)
            
        }else{
            //Zoom out to all of San Diego
            isVerifiedFlag = false
            verifiedButton.setImage(UIImage(named: "OrgUnfilled"), for: UIControlState.normal)
            let SDspan = MKCoordinateSpanMake(0.269, 0.269)
            let SDregion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 32.793181, longitude: -117.164898), span: SDspan)
            mapView.setRegion(SDregion, animated: true)
        }
       // displayRelevantEvents()
    }
    
    func infoButtonTapped() {
        MeasurementHelper.infoEventAnnotationEvent()
        performSegue(withIdentifier: "detailEventVC", sender: self)
    }
    /*
    //Event Button Click Variations
    @IBAction func addEventButtonClicked(_ sender: Any) {
        print("add event button clicked.")
        //eventDescriptive.isHidden = false
        //eventPin.isHidden = false
        //addEventButton.isHidden = true
        //subtractEventButton.isHidden = false
    }
    
    @IBAction func subtractEventButtonClicked(_ sender: Any) {
        eventPin.isHidden = true
        eventDescriptive.isHidden = true
        addEventButton.isHidden = false
        subtractEventButton.isHidden = true
    }
    */
    
    //this method will be called each time when a user change his location access preference.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            print("User allowed us to access location")
            //do whatever init activities here.
        }
    }
    
 
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Errors: " + error.localizedDescription)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*
        if(segue.identifier == "AddEventDescription") {
            let nav = segue.destination as! UINavigationController
            let destinationViewController = nav.viewControllers[0] as! AddEventViewController
            destinationViewController.location = addEventLocation
        }
        */
        if (segue.identifier == "EventInfo") {
            let nav = segue.destination as! UINavigationController
            let destinationViewController = nav.viewControllers[0] as! EventInfoViewController
            let annotation: CampusLiveAnnotation = sender as! CampusLiveAnnotation
            
            
            //print("eventID: \(annotation.eventID)")
            //print("Title: \(annotation.title)")

            destinationViewController.titleEvent = annotation.title
            destinationViewController.subtitleEvent = annotation.subtitle
            destinationViewController.imageEventUrl = annotation.imageUrl
            destinationViewController.startDateStr = annotation.startDate
            destinationViewController.endDateStr = annotation.endDate
            destinationViewController.eventId = annotation.eventID
            destinationViewController.coordinate = annotation.coordinate
        }
    }
    
}

extension LiveViewController: MKMapViewDelegate{
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        SVProgressHUD.dismiss()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        
        if let annotation = annotation as? CampusLiveAnnotation {
            let identifier = "AnnotationIdentifier"
            var view: MKAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier){ // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.image = UIImage(named: "bgpin")

               // print("eventID: \(annotation.eventID)")
                let imageUrl: URL = NSURL(string: annotation.imageUrl) as! URL
                var data = try? Data(contentsOf: imageUrl)
                var profileImage : UIImage = UIImage(data: data!)!
                
                data = UIImageJPEGRepresentation(profileImage, 0.0)
                profileImage = UIImage(data: data!)!
                
                let eventUserImage : UIImageView = UIImageView(image: profileImage)
                
                eventUserImage.layer.borderWidth = 1.5
                //eventUserImage.layer.borderColor = otherEvents.cgColor
                
                // creating colors
                let otherEvents = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha:1.0)
                let live_events = UIColor(red: 1.0, green: 0.0, blue: 57/255.0, alpha: 1.0)
                let trending = UIColor(red: 0.0, green: 1, blue: 216/255.0, alpha: 1.0)
                let events = UIColor(red: 27/255.0, green: 150/255.0, blue: 254/255.0, alpha: 1.0)
                let experiences = UIColor(red: 164/255.0, green: 50/255.0, blue: 1.0, alpha: 1.0)
                let twentyOnePlus = UIColor(red: 0.0, green: 51/255.0, blue: 102/255.0, alpha: 1.0)
                let check_ins = UIColor(red: 67/255.0, green: 199/255.0, blue: 61/255.0, alpha: 1.0)
                
                print("colorType: \(annotation.colorType)")
                //eventUserImage.layer.borderColor = otherEvents.cgColor
                
                
                let f = CGRect(x: 1, y: 1, width: 30, height: 30) // CGRect(2,2,46,43)
                eventUserImage.frame = f
                eventUserImage.layer.cornerRadius = 15.0
                eventUserImage.layer.masksToBounds = true
                
                view.addSubview(eventUserImage)
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = NSLocale.current
                
                let dateAsString = annotation.startDate
                dateFormatter.dateFormat = "yyyy-MM-dd h:mm a"
                let newDate = dateFormatter.date(from: dateAsString!)
                
                // using current date and time as an example
                let someDate = Date()
                
                // convert Date to TimeInterval (typealias for Doub
                let timeInterval = someDate.timeIntervalSince1970
                let integerDate = newDate?.timeIntervalSince1970
                
                let formatter: DateFormatter = DateFormatter()
                formatter.dateFormat = "E HH:mm"
                //let stringDate: String = formatter.string(from: newDate!)
                
                let endDateString = annotation.endDate
                let endDateTime = dateFormatter.date(from: endDateString!)
                let endDateInt = endDateTime?.timeIntervalSince1970
                
                if (integerDate! < timeInterval) {
                    if(timeInterval < endDateInt!){
                        eventUserImage.layer.borderColor = live_events.cgColor
                        //eventUserImage.layer.borderColor = trending.cgColor
                        print("live")
                        let btn2 = UIButton()
                        btn2.frame = CGRect(x: 0, y: 0, width: 38, height: 20)
                        btn2.setImage(UIImage(named: "live"), for: UIControlState())
                        view.rightCalloutAccessoryView = btn2
                    }else{
                        let btn2 = UIButton()
                        btn2.frame = CGRect(x: 0, y: 0, width: 18, height: 20)
                        btn2.setImage(UIImage(named: "Info Button-1"), for: UIControlState())
                        view.rightCalloutAccessoryView = btn2
                    }
                    /*
                    if(AppState.sharedInstance.userPostCount! > 1){
                        AppState.sharedI
                     nstance.userPostCount = AppState.sharedInstance.userPostCount! - 1
                        self.users.child(self.uid!).updateChildValues(["postCount" : AppState.sharedInstance.userPostCount as Any])
                    }
                    */
                    
                    //Don't want an event deletion to be initiated from client side. 
                    /*
                    eventRef.child(annotation.eventID!).removeValue { (error, ref) in
                        print("DELETEEEEEEEEEE")
                        //AppState.sharedInstance.userPostCount = AppState.sharedInstance.userPostCount! - 1
                        //self.users.child(self.uid!).updateChildValues(["postCount" : AppState.sharedInstance.userPostCount])
                        if error != nil {
                            print("error \(error)")
                        }
                    }
                    */
                }
                else{
                    print("Trending")
                  switch annotation.colorType! {
                    case "Trending":
                        eventUserImage.layer.borderColor = trending.cgColor
                        break
                    case "Event":
                        eventUserImage.layer.borderColor = events.cgColor
                        break
                    case "Experiences":
                        eventUserImage.layer.borderColor = experiences.cgColor
                        break
                    case "21+":
                        eventUserImage.layer.borderColor = twentyOnePlus.cgColor
                        break
                    case "check_ins":
                        eventUserImage.layer.borderColor = check_ins.cgColor
                        break
                    //case "other":
                      //  eventUserImage.layer.borderColor = otherEvents.cgColor
                       // break
                    default:
                        eventUserImage.layer.borderColor = otherEvents.cgColor
                        break
                    }
                    let btn2 = UIButton()
                    btn2.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                    btn2.setImage(UIImage(named: "info"), for: UIControlState())
                    view.rightCalloutAccessoryView = btn2
                }
                
                /*
                users.observe(.value, with: {(snap) in
                    if let userDict = snap.value as? [String: AnyObject] {
                        
                        for each in userDict as [String: AnyObject] {
                            if each.key == annotation.eventID {
                                view.image = UIImage(named: "purpleCircularPin")
                                break
                            }
                        }
                    }
                })
                */
                
                view.isEnabled = true
                view.canShowCallout = true
                //view.leftCalloutAccessoryView = UIImageView(image: pikeImage)
                view.leftCalloutAccessoryView = UIImageView(image: eventUserImage.image)
                
                //Custom Left Callout Image Settings
                view.leftCalloutAccessoryView?.contentMode = .scaleAspectFit
                view.leftCalloutAccessoryView?.frame = CGRect(x: CGFloat(5), y: CGFloat(5), width: CGFloat(40), height: CGFloat(40))
                    
                    //CGFloat(eventPin.frame.size.height - 15), height: eventPin.frame.size.height - 15)
                view.leftCalloutAccessoryView?.layer.cornerRadius = (view.leftCalloutAccessoryView?.frame.width)!/2
                view.leftCalloutAccessoryView?.clipsToBounds = true
                
                // btn2.addTarget(self, action: "infoButtonTapped", for: .touchUpInside)
            }
            return view
        }
        return nil
    }
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        // geoCode(location)
        
        /**
        let span = MKCoordinateSpanMake(0.269, 0.269)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 32.793181, longitude: -117.164898), span: span)
        mapView.setRegion(region, animated: true)
        */
        
        UIView.animate(withDuration: 0.4, animations: {
            //self.eventDescriptive.layer.opacity = 1
            
            self.addEventLocation = self.location.coordinate
        })
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        UIView.animate(withDuration: 0.4, animations: {
           // self.eventDescriptive.layer.opacity = 0
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
            /*
            eventPin.isHidden = true
            subtractEventButton.isHidden = true
            addEventButton.isHidden = false
            eventDescriptive.isHidden = true
            print("Right callout Accessory  View Called")
            */
        }
    }
   
    
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
       //SVProgressHUD.show(withStatus: "Loading Map :)")
       SVProgressHUD.show()
        
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        SVProgressHUD.dismiss(withDelay: 0.5)
        
    }
    
}
