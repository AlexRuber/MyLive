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

class MyProfileViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var campusSegment: UISegmentedControl!
   
    
    //var showCampus: Bool?
    
    //Back Button
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func logoutBtnPressed(_ sender: Any) {
   //MARK: Actions
        
        //signs the user out of firebase app
        try! FIRAuth.auth()!.signOut()
        
        //sign the user out of facebook app
        FBSDKAccessToken.setCurrent(nil)
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginView")
        self.present(viewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Profile View Controller Loaded.")
        
        //Making Profile Image a Circle
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2
        self.profileImage.clipsToBounds = true
        
        if FIRAuth.auth()?.currentUser != nil {
            // User is signed in.
            let user = FIRAuth.auth()?.currentUser
            let email = user?.email
            //let uid = user?.uid
            let photoURL = user?.photoURL
            let name = user?.displayName
            
            self.profileName.text = name
            //self.uiEmailLabelView.text = email
            if let photo = photoURL {
                let data = NSData(contentsOf: photo)
                self.profileImage.image = UIImage(data: data! as Data)
            }
            campusSegment.isHidden = true
            
            
            if(AppState.sharedInstance.showCampus)!{
                campusSegment.isHidden = false
                addCampusToSegment()
            }
        } else {
            print("User not Signed In.")
        }
        
    }
    
    func addCampusToSegment(){
        
        campusSegment.removeAllSegments()
        let userDict = AppState.sharedInstance.campusDict
        var i = 0
        for each in userDict! {
            //AppState.sharedInstance.dafaultCampus = each.key
            campusSegment.insertSegment(withTitle: each.key, at: i, animated: true)
            i += 1
        }
    }
    
    @IBAction func segmentValueChanged(_ sender: Any) {
        let userDict = AppState.sharedInstance.campusDict
        
        for each in userDict as! [String: AnyObject]{
            if(each.key == campusSegment.titleForSegment(at: campusSegment.selectedSegmentIndex)!){
                AppState.sharedInstance.dafaultCampus = each.key
                AppState.sharedInstance.defaultLatitude = each.value["latitude"] as? NSNumber
                AppState.sharedInstance.defaultLongitude = each.value["longitude"] as? NSNumber
                //self.dismiss(animated: true, completion: nil)
                
                
            let secondViewController = self.storyboard!.instantiateViewController(withIdentifier: "HomeView")
            self.present(secondViewController, animated: true, completion: nil)
        }
        }
        //AppState.sharedInstance.dafaultCampus = userDict?[campusSegment.titleForSegment(at: campusSegment.selectedSegmentIndex)!] as! String
         //print(AppState.sharedInstance.dafaultCampus)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
