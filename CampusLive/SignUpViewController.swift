//
//  SignUpViewController.swift
//  CampusLive
//
//  Created by Raghav Nyati on 1/23/17.
//  Copyright © 2017 Mihai Ruber. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    let userRef = FIRDatabase.database().reference().child("org")
    var uid: String?
    var isSwitchOn: Bool = false
    
    @IBOutlet weak var termsSwitch: UISwitch!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var fbTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var orgNameTextField: UITextField!
    @IBOutlet weak var adminTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        termsSwitch.isOn = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func termsSwitchValueChanged(_ sender: Any) {
        if(termsSwitch.isOn){
            isSwitchOn = true
        }
        else{
            isSwitchOn = false
        }
    }
    
    @IBAction func signupButtonClicked(_ sender: Any) {
        if !(emailTextField.text?.isEmpty)! && !(passwordTextField.text?.isEmpty)! && (isSwitchOn){
            guard let email = emailTextField.text, let password = passwordTextField.text else { return }
            FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                let alert = UIAlertController(title: "Success", message: "User Registered Sucessfully", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                self.setDisplayName(user!)
                self.post()
            }
        }
        else{
            let alert = UIAlertController(title: "Invalid Fields", message: "Enter all details and agree to Privacy Policy", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func post(){
        
        let email = emailTextField.text
        let currentDate = String(describing: Date())
        let org = orgNameTextField.text
        let admin = adminTextField.text
        let web = websiteTextField.text
        let fb = fbTextField.text
        let phone = phoneTextField.text
        
        let posts: [String : AnyObject] = ["email":email as AnyObject, "org":org as AnyObject, "admin":admin as AnyObject, "website":web as AnyObject, "fb":fb as AnyObject, "phone":phone as AnyObject, "creationDate":currentDate as AnyObject]
        userRef.child(uid!).setValue(posts)
        print("Posting value ")
    }
    
    func setDisplayName(_ user: FIRUser) {
        let changeRequest = user.profileChangeRequest()
        changeRequest.displayName = user.email!.components(separatedBy: "@")[0]
        changeRequest.commitChanges(){ (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
        //print("User Signed Up : Need to perfom a Segue.")
        self.signedIn(FIRAuth.auth()?.currentUser)
    }
    
    func signedIn(_ user: FIRUser?) {
        MeasurementHelper.sendLoginEvent()
        self.uid = user?.uid
        AppState.sharedInstance.displayName = user?.displayName ?? user?.email
        AppState.sharedInstance.photoURL = user?.photoURL
        AppState.sharedInstance.signedIn = true
        let notificationName = Notification.Name(rawValue: Constants.NotificationKeys.SignedIn)
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: nil)
        //performSegue(withIdentifier: Constants.Segues.SignInToFp, sender: nil)
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
