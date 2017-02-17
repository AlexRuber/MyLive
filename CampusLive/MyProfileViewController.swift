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
        
        //self.uiImageView.layer.cornerRadius = self.uiImageView.frame.size.width/2
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
            
        } else {
            print("User not Signed In.")
        }
        
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
