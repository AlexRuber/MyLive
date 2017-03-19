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
import FirebaseDatabase
import FirebaseAuth
import SVProgressHUD

class AddEventViewController: UIViewController, UITextFieldDelegate {
    
    var location: CLLocationCoordinate2D!
    
    var userRef = FIRDatabase.database().reference()
    var users = FIRDatabase.database().reference()
    var storage = FIRStorage.storage().reference()
    var ref: FIRDatabaseReference! = FIRDatabase.database().reference().child("app_defaults")
    var uid: String?
    var defaultPostCount: Int!
    
    var isOrgLogin: Bool = false
    
    //Outlet for Profile Image (connected with Firebase)
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var venueTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    //@IBOutlet weak var descriptionTextView: UITextView!
    //@IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!
 
    
    @IBAction func backButtonClicked(_ sender: Any) {
        hideKeyBoard()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func didTapPost(_ sender: Any) {
        
        print("USER POST COUNT:  \(AppState.sharedInstance.userPostCount!)")
        if ((venueTextField.text?.isEmpty)! || (nameTextField.text?.isEmpty)!){
            let alert = UIAlertController(title: "Invalid Fields", message: "Enter all details", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }
        else if (FIRAuth.auth()?.currentUser != nil && AppState.sharedInstance.userPostCount! <= 100) {
            // User is signed in.
            
            self.uid = FIRAuth.auth()?.currentUser?.uid
            
            let data = try? Data(contentsOf: AppState.sharedInstance.photoURL!) // make sure your image in this url does exist,otherwise unwrap in a if let check try-catch
            
            let img: UIImage = UIImage(data: data!)!
            
            var downloadURL: String?
            
            if let imgData = UIImageJPEGRepresentation(img, 0.2) {
                
                let imgID = UUID().uuidString
                let metadata = FIRStorageMetadata()
                metadata.contentType = "image/jpeg"
                
                storage.child(imgID).put(imgData, metadata: metadata) { (metadata, error) in
                    if error != nil {
                        print("Max: Unable to store images in Firebase storage")
                    } else {
                        print("Max: Succesfully stored images in Firebase storage")
                        downloadURL = (metadata?.downloadURL()!.absoluteString)!
                        self.post(imageUrl: downloadURL!)
                        
                        //print("MAXMAXMAXMAXMAX: \(downloadURL!)")
                        //self.postToFirebase(downloadURL!)
                    }
                }
            }
            
            let addEventPopup = UIAlertController(title: "Posted", message: "Your event is now on the map", preferredStyle: .alert)
            //let defaultAction = UIAlertAction(title: "Close", style: .default, handler: nil)
            addEventPopup.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                action in
                //Settings for the loading spinner
                let foregroundColor = UIColor(red: 27/255, green: 150/255, blue: 254/255, alpha: 1)
                let backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
                SVProgressHUD.setForegroundColor(foregroundColor)
                SVProgressHUD.setBackgroundColor(backgroundColor)
                SVProgressHUD.show(withStatus: "Posting event")
                
                //present view controller, not dismissed, but reloaded from prototype
                self.dismiss(animated: true, completion: nil)
                
            }
                )
            )
            present(addEventPopup, animated: true, completion: nil)
            //self.dismiss(animated: true, completion: nil)
            
        } else {
            
            if (AppState.sharedInstance.userPostCount! >= 3){
                let alert = UIAlertController(title: "Uh Oh!", message: "You have reached the max number of events for the day.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                present(alert, animated: true, completion: nil)
                
            }
            else {
            let addEventPopup = UIAlertController(title: "Error!", message: "Something went wrong.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Close", style: .default, handler: nil)
            addEventPopup.addAction(defaultAction)
            present(addEventPopup, animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
            }
            
        }
    }
    
    func dismissView() {
        hideKeyBoard()
        self.dismiss(animated: true, completion: nil)
    }
    
    func setUserPostCount(count: Int) {
        AppState.sharedInstance.userPostCount = count
    }
    
    func post(imageUrl: String) {
        let name = nameTextField.text
        let venue = venueTextField.text
        let description = descriptionTextView.text
        //print(description)
        
        //d.setTime( d.getTime() + d.getTimezoneOffset()*60*1000 );
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd hh:mm a"
        
        //let startDate = String(describing: startDatePicker.date)
        let endDate = dateFormatter.string(from: endDatePicker.date)
        print(endDate)
        
        let startDate = dateFormatter.string(from: startDatePicker.date)
        print(startDate)
        
        let currentDate = Date()
        let currentDateTimeInterval = currentDate.timeIntervalSince1970
        let dayFromNow = currentDateTimeInterval + 86400.0
        let newDate = dateFormatter.date(from: startDate)
        let startDateTimeInterval = newDate?.timeIntervalSince1970
        
        userRef = userRef.childByAutoId()
        userRef.setValue(posts)
        
        let userPost: Dictionary<String, AnyObject> = [ userRef.key : true as AnyObject ]
        
        users.child(uid!).updateChildValues(userPost)
        
        AppState.sharedInstance.userPostCount = AppState.sharedInstance.userPostCount! + 1
        users.child(uid!).updateChildValues(["postCount" : AppState.sharedInstance.userPostCount])
        
        print("Posting event success.")
        SVProgressHUD.dismiss(withDelay: 2.0)
    }
    
    func hideKeyBoard(){
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref.observeSingleEvent(of: .value, with: {snapshot in
            if !snapshot.exists(){return}
            //let dict = snapshot.value as? NSDictionary
            //let postCount = dict.value["max_post_count"] as? Int
            self.defaultPostCount = (snapshot.value as? NSDictionary)?["max_post_count"] as! Int
            print(self.defaultPostCount)
        })
        
        
        //let postCount: Dictionary<String, AnyObject> = [ defaults.key : true as AnyObject ]
        //defaultPostCount = defaults.value(forKey: "max_post_count") as! Int!
        //print(defaultPostCount)
        
        //Settings for Profile imageview
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        self.profileImage.clipsToBounds = true
        
        if FIRAuth.auth()?.currentUser != nil {
            // User is signed in.
            let user = FIRAuth.auth()?.currentUser
            //let email = user?.email
            //let uid = user?.uid
            let photoURL = user?.photoURL
            //let name = user?.displayName
            
            //self.uiEmailLabelView.text = email
            if let photo = photoURL {
                let data = NSData(contentsOf: photo)
                self.profileImage.image = UIImage(data: data! as Data)
            }
            
        } else {
            print("User not Signed In.")
        }
        
        
        //Hiding keyboard delegates
        self.venueTextField.delegate = self
        self.nameTextField.delegate = self
        
        print(location)
        
        if(isOrgLogin){
            userRef = userRef.child("org_events")
        }else{
            userRef = userRef.child("stu_events")
        }
        
        users = users.child("users")
        self.uid = FIRAuth.auth()?.currentUser?.uid
        
        users.child(uid!).observeSingleEvent(of: .value, with: {(snap) in
            let userDict = snap.value as? NSDictionary
            let postCount = userDict?["postCount"] as! Int
            self.setUserPostCount(count: postCount)
        })
        
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
        let maxLengthName = 27
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
