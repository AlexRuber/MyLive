//
//  MyProfileViewController.swift
//  CampusLive
//
//  Created by Raghav Nyati on 1/23/17.
//  Copyright © 2017 Mihai Ruber. All rights reserved.
//

import UIKit
import Firebase
import Foundation
import FirebaseStorage
import FirebaseDatabase
import FBSDKLoginKit
import CoreLocation

class MyProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    
    @IBOutlet weak var checkInsTableView: UITableView!

    let uid = FIRAuth.auth()?.currentUser?.uid
    var user_checkins = FIRDatabase.database().reference()
    var events = FIRDatabase.database().reference()
    var messages: [FIRDataSnapshot]! = []
    var checkInsArray = [String]()
    var eventsArray : [Event] = []
    var eventTitle: String!
    var startDate: String!
    var indexPath: Int?

    //Back Button
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func logoutBtnPressed(_ sender: Any) {
        
        MeasurementHelper.sendLogoutEvent()
        try! FIRAuth.auth()!.signOut()

        FBSDKAccessToken.setCurrent(nil)
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginView")
        self.present(viewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user_checkins = user_checkins.child("user_checkins").child(self.uid!)
        events = events.child("events")
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        checkInsTableView.delegate = self
        checkInsTableView.dataSource = self
    
        //Making Profile Image a Circle
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2
        self.profileImage.clipsToBounds = true
        
        if FIRAuth.auth()?.currentUser != nil {
           
            let user = FIRAuth.auth()?.currentUser
            _ = user?.email
            
            let photoURL = user?.photoURL
            let name = user?.displayName
            
            self.profileName.text = name
            
            if let photo = photoURL {
                let data = try? Data(contentsOf: photo) //throws // try Data(contentsOf: photo)
                self.profileImage.image = UIImage(data: data!)
            }
            
            if(AppState.sharedInstance.showCampus)!{
                //campusSegment.isHidden = false
                //addCampusToSegment()
            }
        } else {
            print("User not Signed In.")
        }
        
        self.eventsArray.removeAll()
        self.checkInsArray.removeAll()
        
        loadFirebaseData()
        
        checkInsTableView.delegate = self
        checkInsTableView.dataSource = self
        
    }
    
    func loadFirebaseData() {
        DispatchQueue.main.async {
            self.user_checkins.observe(.value, with: {(snap) in
                if let userDict = snap.value as? [String: AnyObject] {
                    for each in userDict as [String: AnyObject] {
                        self.checkInsArray.append(each.key)
                    }
                    DispatchQueue.main.async {
                        self.events.observe(.value, with: {(snap) in
                            if let userDict = snap.value as? [String: AnyObject] {
                                
                                for each in userDict as [String: AnyObject] {
                                    
                                    for i in 0..<self.checkInsArray.count {
                                        if (each.key == self.checkInsArray[i]) {
                                            let autoID = each.key
                                            let title = each.value["title"] as! String
                                            let startDate = each.value["startDate"] as! String
                                            
                                            let venue = each.value["venue"] as! String
                                            let endDate = each.value["endDate"] as! String
                                            let latitude = each.value["latitude"] as! NSNumber
                                            let longitude = each.value["longitude"] as! NSNumber
                                            let imageUrl = each.value["image"] as! String
                                            
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.locale = NSLocale.current
                                            dateFormatter.dateFormat = "yyyy-MM-dd h:mm a"
                                            let formatter: DateFormatter = DateFormatter()
                                            formatter.dateFormat = "E hh:mm a"
                                            let newStartDate = dateFormatter.date(from: startDate)
                                            let newEndDate = dateFormatter.date(from: endDate)
                                            
                                            let newEnd = formatter.string(from: newEndDate!)
                                            let newStart = formatter.string(from: newStartDate!)
                                            
                                            self.eventsArray.append(Event(lat: CLLocationDegrees(latitude), long: CLLocationDegrees(longitude), title: title, subtitle: venue, imageUrl: imageUrl, eventId: autoID, endDate: newEnd, startDate: newStart, unformattedStartDate: startDate, unformattedEndDate: endDate))
                                            
                                            DispatchQueue.main.async() {
                                                self.checkInsTableView.reloadData()
                                            }
                                            
                                        }
                                    }
                                }
                            }
                        })
                    }
                    
                }
                
            })
        }
       
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checkInsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CheckInTableViewCell
        
        cell?.eventTitleLabel.text = eventsArray[indexPath.row].title
        cell?.eventDateLabel.text = eventsArray[indexPath.row].startDate
        cell?.venueLabel.text = eventsArray[indexPath.row].subtitle
        cell?.infoButton.tag = indexPath.row
        cell?.infoButton.addTarget(self, action: #selector(infoButtonPressed), for: .touchUpInside)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    @IBAction func infoButtonPressed(_ sender: Any) {
        self.indexPath = (sender as AnyObject).tag
        performSegue(withIdentifier: "detailSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            if let indexPath = self.indexPath { //checkInsTableView.indexPathForSelectedRow {
                let nav = segue.destination as! UINavigationController
                let destinationViewController = nav.viewControllers[0] as! EventInfoViewController
                destinationViewController.titleEvent = eventsArray[indexPath].title
                destinationViewController.subtitleEvent = eventsArray[indexPath].subtitle
                destinationViewController.imageEventUrl = eventsArray[indexPath].imageUrl
                destinationViewController.startDateStr = eventsArray[indexPath].unformattedStartDate
                destinationViewController.endDateStr = eventsArray[indexPath].unformattedEndDate
                destinationViewController.eventId = eventsArray[indexPath].eventId
                destinationViewController.coordinate = eventsArray[indexPath].coordinate
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
