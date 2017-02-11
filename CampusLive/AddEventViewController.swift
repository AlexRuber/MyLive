//
//  AddEventViewController.swift
//  CampusLive
//
//  Created by Raghav Nyati on 2/10/17.
//  Copyright © 2017 Mihai Ruber. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class AddEventViewController: UIViewController {

    var location: CLLocation!
    
    let userRef = FIRDatabase.database().reference().child("event")
    var uid: String?
    
    @IBOutlet weak var venueTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBAction func postButtonClicked(_ sender: Any) {
        if FIRAuth.auth()?.currentUser != nil{
            // User is signed in.
            self.uid = FIRAuth.auth()?.currentUser?.uid
            self.post()
        }
    }
    
    func post(){
        
        let name = nameTextField.text
        let venue = venueTextField.text
        let description = descriptionTextView.text
        let startDate = String(describing: startDatePicker.date)
        let endDate = String(describing: endDatePicker.date)
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        let posts: [String : AnyObject] = ["uid":uid as AnyObject, "name":name as AnyObject, "venue":venue as AnyObject, "description":description as AnyObject, "startDate":startDate as AnyObject, "endDate":endDate as AnyObject, "latitude":latitude as AnyObject, "longitude":longitude as AnyObject]
        userRef.childByAutoId().setValue(posts)
        print("Adding an event successfully.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Add event View did load called.")
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
