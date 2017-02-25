//
//  SignUpViewController.swift
//  CampusLive
//
//  Created by Raghav Nyati on 1/23/17.
//  Copyright © 2017 Mihai Ruber. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class SignUpViewController: UIViewController, UITextFieldDelegate{

    let userRef = FIRDatabase.database().reference().child("org")
    var uid: String?
    var isSwitchOn: Bool = false
    
    @IBOutlet weak var termsSwitch: UISwitch!
    @IBOutlet weak var addImageBackButton: UIButton!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var fbTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var orgNameTextField: UITextField!
    @IBOutlet weak var adminTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var instaTextField: UITextField!
    
    @IBAction func backBtnPressed(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        termsSwitch.isOn = false
        
        //Creating Delegates for Hiding Keyboard
        self.phoneTextField.delegate = self
        self.fbTextField.delegate = self
        self.websiteTextField.delegate = self
        self.orgNameTextField.delegate = self
        self.adminTextField.delegate = self
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.instaTextField.delegate = self
        
        addImageBackButton.layer.cornerRadius = addImageBackButton.frame.size.width / 2
        addImageBackButton.layer.cornerRadius = addImageBackButton.frame.size.height / 2
        addImageBackButton.clipsToBounds = true

    
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
        let insta = instaTextField.text
        
        let posts: [String : AnyObject] = ["email":email as AnyObject, "org":org as AnyObject, "admin":admin as AnyObject, "website":web as AnyObject, "fb":fb as AnyObject, "instagram":insta as AnyObject, "phone":phone as AnyObject, "creationDate":currentDate as AnyObject]
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
        performSegue(withIdentifier: Constants.Segues.SignUpToFp, sender: nil)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        //let viewController = segue.destination as!
        //viewController.isOrgLogin = true
        if(segue.identifier == "SignUpToFP"){
            //let barViewControllers = segue.destination as! UITabBarController
            //let nav = barViewControllers.viewControllers![0] as! UINavigationController
            //let destinationViewController = nav.viewControllers[0] as! LiveViewController
            let destinationViewController = segue.destination as! LiveViewController
            destinationViewController.isOrgLogin = true
           // destinationViewController.isOrgLogin = true
        }
    }

}
