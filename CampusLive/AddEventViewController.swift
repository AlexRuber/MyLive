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

class AddEventViewController: UIViewController, UITextFieldDelegate {

    var location: CLLocationCoordinate2D!
    
    var userRef = FIRDatabase.database().reference()
    var uid: String?
    
    var isOrgLogin: Bool = false
    
    @IBOutlet weak var venueTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBAction func fbLinkTapped(_ sender: Any) {
        UIApplication.shared.openURL(NSURL(string: "https://www.facebook.com/UcsdPike/")! as URL)

    }
    
    @IBAction func instaLinkTapped(_ sender: Any) {
        UIApplication.shared.openURL(NSURL(string: "https://www.instagram.com/ucsdpike/?hl=en")! as URL)

    }
   
    @IBAction func webLinkTapped(_ sender: Any) {
        UIApplication.shared.openURL(NSURL(string: "http://www.ucsdpike.org")! as URL)

    }
    
    
    
    @IBAction func backButtonClicked(_ sender: Any) {
            hideKeyBoard()
            self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postButtonClicked(_ sender: Any) {
        if FIRAuth.auth()?.currentUser != nil{
            // User is signed in.
            self.uid = FIRAuth.auth()?.currentUser?.uid
            self.post()
            
            let addEventPopup = UIAlertController(title: "Posted", message: "Your event is now on the map", preferredStyle: .alert)
            //let defaultAction = UIAlertAction(title: "Close", style: .default, handler: nil)
            addEventPopup.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                action in
                self.dismiss(animated: true, completion: nil)
            }))
            present(addEventPopup, animated: true, completion: nil)
            //self.dismiss(animated: true, completion: nil)
            //dismissView()
        }else{
            let addEventPopup = UIAlertController(title: "Error!", message: "Something went wrong.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Close", style: .default, handler: nil)
            addEventPopup.addAction(defaultAction)
            present(addEventPopup, animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func dismissView(){
            hideKeyBoard()
            self.dismiss(animated: true, completion: nil)
    }
    
    func post(){
        let name = nameTextField.text
        let venue = venueTextField.text
        let description = descriptionTextView.text
        let startDate = String(describing: startDatePicker.date)
        let endDate = String(describing: endDatePicker.date)
        let latitude = location.latitude
        let longitude = location.longitude
        
        let posts: [String : AnyObject] = ["uid":uid as AnyObject, "name":name as AnyObject, "venue":venue as AnyObject, "description":description as AnyObject, "startDate":startDate as AnyObject, "endDate":endDate as AnyObject, "latitude":latitude as AnyObject, "longitude":longitude as AnyObject]
        userRef.childByAutoId().setValue(posts)
        print("Posting event success.")
    }
    
    func hideKeyBoard(){
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Hiding keyboard delegates
        self.venueTextField.delegate = self
        self.nameTextField.delegate = self
        
        print(location)
        
        if(isOrgLogin){
            userRef = userRef.child("org_events")
        }else{
            userRef = userRef.child("stu_events")
        }
        
        hideKeyBoard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //Hide keyboard when user touches outside keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //Hide after pressing enter key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return (true)
        
    }
}
