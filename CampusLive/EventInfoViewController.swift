//
//  EventInfoViewController.swift
//  CampusLive
//
//  Created by Mihai Ruber on 3/3/17.
//  Copyright © 2017 Mihai Ruber. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class EventInfoViewController: UIViewController {
    
    var userRef = FIRDatabase.database().reference()
    var ref: FIRDatabaseReference!
    //var eventRef: FIRDatabaseReference!
    var eventInfoRef: FIRDatabaseReference!
    
    var uid: String!
    
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventSubtitle: UILabel!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var eventProfileImage: UIImageView!
    
    @IBOutlet weak var goingbutton: UIButton!
    
    
    //@IBOutlet weak var startDate: UILabel!
    //@IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var startDate: UILabel!
    
    var titleEvent: String?
    var subtitleEvent: String?
    var descriptionEvent: String?
    var imageEventUrl: String?
    var startDateStr: String?
    var endDateStr: String?
    var eventId: String?
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventDescription.isEditable = false
        
        self.title = titleEvent
        
        ref = FIRDatabase.database().reference()
        //eventRef = FIRDatabase.database().reference().child("events")
        eventInfoRef = FIRDatabase.database().reference().child("event_social_info")
        
        eventTitle?.text = titleEvent
        eventSubtitle?.text = subtitleEvent
        
        //eventDescription.text = descriptionEvent
        //print(endDateStr)
        startDate.text = endDateStr
        //startDate.isHidden = true
        
        displayEventInfo()
        
        let imageUrl: URL = NSURL(string: imageEventUrl!) as! URL
        
        let data = try? Data(contentsOf: imageUrl)
        
        let profileImage : UIImage = UIImage(data: data!)!
        
        eventProfileImage.image = profileImage
        
        eventProfileImage.layer.cornerRadius = eventProfileImage.frame.size.width / 2
        eventProfileImage.layer.cornerRadius = eventProfileImage.frame.size.height / 2
        eventProfileImage.clipsToBounds = true
        
        // Do any additional setup after loading the view.
    }
    
    func displayEventInfo(){
        eventInfoRef.child(eventId!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let description = value?["description"] as? String ?? ""
            //let user = User.init(username: username)
            self.eventDescription.text = description
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    @IBAction func reportEventClicked(_ sender: Any) {
        self.uid = FIRAuth.auth()?.currentUser?.uid
        let posts: [String : AnyObject] = ["reported By": uid as AnyObject]
        userRef = userRef.child("malicious_events").child(eventId!)
        userRef.setValue(posts)
        
        let addEventPopup = UIAlertController(title: "Appreciate it!", message: "Thank you for reporting. Our team will shortly look into it.", preferredStyle: .alert)
        addEventPopup.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            action in
            self.dismiss(animated: true, completion: nil)
        }))
        present(addEventPopup, animated: true, completion: nil)
        
    }
    */
    
    @IBAction func onEventCheckedIn(_ sender: Any) {
        
        goingbutton.setTitle("Checked In", for: UIControlState.disabled)
        
        self.uid = FIRAuth.auth()?.currentUser?.uid
        
        let posts: [String : AnyObject] = [eventId!: true as AnyObject]
        userRef = userRef.child("user_checkins").child(uid)
        userRef.setValue(posts)
        
        ref = ref.child("event_users").child(eventId!)
        let post1: [String : AnyObject] = [uid: true as AnyObject]
        ref.setValue(post1)
        
        let addEventPopup = UIAlertController(title: "Done", message: "You have checked-in for the event.", preferredStyle: .alert)
        DispatchQueue.main.async {
            addEventPopup.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                action in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(addEventPopup, animated: true, completion: nil)
        }
    }
    
}
