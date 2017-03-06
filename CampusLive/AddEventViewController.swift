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
    
    //Social Link Code
    
    //Outline Outlets
    @IBOutlet weak var fbOutline: UIImageView!
    @IBOutlet weak var fbEventOutline: UIImageView!
    @IBOutlet weak var snapOutline: UIImageView!
    @IBOutlet weak var instaOutline: UIImageView!
    @IBOutlet weak var webOutline: UIImageView!
    
    //Checkmark Outlets
    @IBOutlet weak var fbCheckMark: UIImageView!
    @IBOutlet weak var fbEventCheckMark: UIImageView!
    @IBOutlet weak var instaCheckMark: UIImageView!
    @IBOutlet weak var webCheckMark: UIImageView!
    @IBOutlet weak var snapCheckMark: UIImageView!
    
    
    
    //Social Button Action Outlets
    @IBAction func fbBtnClicked(_ sender: Any) {
        fbOutline.isHidden = false
        fbCheckMark.isHidden = false

    }
    @IBAction func fbEventBtnClicked(_ sender: Any) {
        
        let prompt = UIAlertController.init(title: nil, message: "Copy Facebook Event URL", preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "OK", style: .default) { (action) in
            let userInput = prompt.textFields![0].text
            if (userInput!.isEmpty) {
                return
            }
            else{
                self.fbEventOutline.isHidden = false
                self.fbEventCheckMark.isHidden = false
            }
        
        }
     
        prompt.addTextField(configurationHandler: nil)
        prompt.addAction(okAction)
        present(prompt, animated: true, completion: nil);
        
    }
    
    @IBAction func snapBtnClicked(_ sender: Any) {
        snapOutline.isHidden = false
        snapCheckMark.isHidden = false
    }
    @IBAction func instaBtnClicked(_ sender: Any) {
        instaOutline.isHidden = false
        instaCheckMark.isHidden = false
        
    }
    @IBAction func webBtnClicked(_ sender: Any) {
        
        
        let prompt = UIAlertController.init(title: nil, message: "Copy Website URL", preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "OK", style: .default) { (action) in
            let userInput = prompt.textFields![0].text
            if (userInput!.isEmpty) {
                return
            }
            else{
                self.webOutline.isHidden = false
                self.webCheckMark.isHidden = false
            }
            
        }
        
        prompt.addTextField(configurationHandler: nil)
        prompt.addAction(okAction)
        present(prompt, animated: true, completion: nil);
        
      
    }
    
    
    
    
    //Link code
  /**
    @IBAction func snapLink(_ sender: Any) {
         UIApplication.shared.openURL(NSURL(string: "https://www.brandonmagpayo.com")! as URL)
    }
    
    @IBAction func instaLink(_ sender: Any) {
         UIApplication.shared.openURL(NSURL(string: "https://www.instagram.com/brandonmonteiro_")! as URL)
    }
    @IBAction func fbLink(_ sender: Any) {
         UIApplication.shared.openURL(NSURL(string: "https://www.facebook.com/brandonmagpayo")! as URL)
    }
    */
    
    @IBAction func backButtonClicked(_ sender: Any) {
            hideKeyBoard()
            self.dismiss(animated: true, completion: nil)
    }
    
   
    @IBAction func postButtonClicked(_ sender: Any) {
        
        if ((venueTextField.text?.isEmpty)! || (nameTextField.text?.isEmpty)!){
            let alert = UIAlertController(title: "Invalid Fields", message: "Enter all details", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            
            
        }
        
        else if FIRAuth.auth()?.currentUser != nil{
            // User is signed in.
            
            
            self.uid = FIRAuth.auth()?.currentUser?.uid
            self.post()
            
            let addEventPopup = UIAlertController(title: "Posted", message: "Your event is now on the map", preferredStyle: .alert)
            //let defaultAction = UIAlertAction(title: "Close", style: .default, handler: nil)
            addEventPopup.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                action in
                
                //present view controller, not dismissed, but reloaded from prototype
              self.dismiss(animated: true, completion: nil)
                }
            )
            )
            present(addEventPopup, animated: true, completion: nil)
            //self.dismiss(animated: true, completion: nil)
            
          
            
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
    
        
        //Initiliaze hidden outline + checkmarks
        fbOutline.isHidden = true
        fbEventOutline.isHidden = true
        snapOutline.isHidden = true
        instaOutline.isHidden = true
        webOutline.isHidden = true
        fbCheckMark.isHidden = true
        fbEventCheckMark.isHidden = true
        instaCheckMark.isHidden = true
        snapCheckMark.isHidden = true
        webCheckMark.isHidden = true
        
    
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
    
    //Check character count
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        let maxLengthName = 17
        let maxLengthVenue = 27
        let currentStringName: String = nameTextField.text!
        let currentStringVenue: String = venueTextField.text!
        
        let newLengthName = currentStringName.characters.count + string.characters.count - range.length
        let newLengthVenue = currentStringVenue.characters.count + string.characters.count - range.length
        
        
        return (newLengthName < maxLengthName && newLengthVenue < maxLengthVenue)
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
