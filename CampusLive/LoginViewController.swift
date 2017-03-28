//
//  SignInViewController.swift
//  CampusLive
//
//  Created by Raghav Nyati on 1/23/17.
//  Copyright © 2017 Mihai Ruber. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKShareKit
import SVProgressHUD

class SignInViewController: UIViewController, UITextFieldDelegate {

    var homeViewController: UIViewController!
    var viewController: UIViewController!
    //var signupViewController: UIViewController!

    var users: FIRDatabaseReference!
    var app_default: FIRDatabaseReference!
    var campusRef: FIRDatabaseReference!
    
    //var isOrgLogin: Bool = false
    

    @IBOutlet weak var logoImage: UIImageView!
    //@IBOutlet weak var usernameField: UITextField!
    //@IBOutlet weak var passwordField: UITextField!
    //@IBOutlet weak var loginInButton: UIButton!
    //@IBOutlet weak var forgetPasswordButton: UIButton!
    //@IBOutlet weak var signupButton: UIButton!
    //@IBOutlet weak var segmentView: UISegmentedControl!
    @IBOutlet weak var customFBButton: UIButton!
    //@IBOutlet weak var activityInd: UIActivityIndicatorView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        users = FIRDatabase.database().reference().child("users")
        
        if(FIRAuth.auth()?.currentUser != nil){
            
            performSegue(withIdentifier: "SignInToFP", sender: self)
        }
        
        //Activity Spinner Hidden to Begin
        //activityInd.isHidden = true
        
        //Creating Delegates for Hiding Keyboard
        //self.usernameField.delegate = self
        //self.passwordField.delegate = self
        
        //Custom FB Button Settings
        let customFBImage = UIImage(named: "facebook-login-blue")
        customFBButton.setImage(customFBImage, for: .normal)
        customFBButton.frame = CGRect(x: 0, y: 0, width: 175, height: 44)
        customFBButton.center = self.view.center
        customFBButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
        
        //segmentView.selectedSegmentIndex = 0
        //usernameField.isHidden = true
        //asswordField.isHidden = true
        //loginInButton.isHidden = true
        //forgetPasswordButton.isHidden = true
        //signupButton.isHidden = true
        //customFBButton.isHidden = false
        
  
    }

    /*
    @IBAction func segmentStateChanged(_ sender: Any) {
        switch segmentView.selectedSegmentIndex{
        case 0:
            usernameField.isHidden = true
            passwordField.isHidden = true
            loginInButton.isHidden = true
            forgetPasswordButton.isHidden = true
            signupButton.isHidden = true
            customFBButton.isHidden = false
        case 1:
            usernameField.isHidden = false
            passwordField.isHidden = false
            loginInButton.isHidden = false
            forgetPasswordButton.isHidden = false
            signupButton.isHidden = false
            customFBButton.isHidden = true
        default:
            break;
        }
    }
    */
    
    
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
  
    //Remember user sign in
    override func viewDidAppear(_ animated: Bool) {
        if (FBSDKAccessToken.current() != nil && FIRAuth.auth()?.currentUser != nil)
        {
            //performSegue(withIdentifier:"SignInToFP", sender: self)
            showEmailAddress()
        }
        
    }
    
    
    func presentHomeViewController(){
        self.present(homeViewController, animated: true, completion: nil)
    }
    
    func presentViewController1(){
        self.present(viewController, animated: true, completion: nil)
    }
    
    func handleCustomFBLogin(){
        //print(1234)
        
        //isOrgLogin = false
        
        self.customFBButton.isHidden = false
        
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile", "user_friends"], from: self){ (result, err) in
            if(err != nil){
                print("Fb Login Failed", err ?? "")
                self.dismiss(animated: true, completion: nil)
            }
            //print(result?.token.tokenString ?? "")
            self.showEmailAddress()
            //self.dismiss(animated: true, completion: nil)

        }
    }
    
    func showEmailAddress(){
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else {
            return
        }
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
        FIRAuth.auth()?.signIn(with: credentials, completion: {(user, error) in
            if(error != nil){
                print("Something went wrong with our FB user: ", error ?? "")
                return
            }
            print("Successfully logged in with our user: ", user ?? "")
            
            let currentDate = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "yyyy-MM-dd h:mm a"
            let newDate = dateFormatter.string(from: currentDate)
            
            let userData: [String : AnyObject] = ["provider": user?.providerID as AnyObject, "createdOn": newDate as AnyObject]
            self.signedIn(user, userID: (user?.uid)!, userData: userData as! Dictionary<String, String>)
        })
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start{
            (connection, result, err) in
            if(err != nil){
                print("Failed to start graph request.")
                return
            }
            print(result ?? "")
        }
    }
    
    /*
    @IBAction func didRequestPasswordReset(_ sender: Any) {
        let prompt = UIAlertController.init(title: nil, message: "Email:", preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "OK", style: .default) { (action) in
            let userInput = prompt.textFields![0].text
            if (userInput!.isEmpty) {
                return
            }
            FIRAuth.auth()?.sendPasswordReset(withEmail: userInput!) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            }
        }
        prompt.addTextField(configurationHandler: nil)
        prompt.addAction(okAction)
        present(prompt, animated: true, completion: nil);
    }
    */
    
    func signedIn(_ user: FIRUser?, userID: String, userData: Dictionary<String, String>) {
        
        MeasurementHelper.sendLoginEvent()
        AppState.sharedInstance.displayName = user?.displayName ?? user?.email
        AppState.sharedInstance.photoURL = user?.photoURL
        AppState.sharedInstance.signedIn = true
        
        let imageUrl: Dictionary<String, String> = [
            "profileImage": (user?.photoURL?.absoluteString)!
            ]
        
        users.child(userID).updateChildValues(userData)
        users.child(userID).updateChildValues(imageUrl)
        
        DispatchQueue.main.async {
            self.checkCampus()
            self.selectCampus()
        }
        
        //let notificationName = Notification.Name(rawValue: Constants.NotificationKeys.SignedIn)
        //NotificationCenter.default.post(name: notificationName, object: nil, userInfo: nil)
        //performSegue(withIdentifier: Constants.Segues.SignInToFp, sender: nil)
    
    }
    
    /*
    func doNothing(){
        var inputTextField: UITextField?
        let passwordPrompt = UIAlertController(title: "Campus", message: "Select your Campus.", preferredStyle: UIAlertControllerStyle.alert)
        passwordPrompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        passwordPrompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            // Now do whatever you want with inputTextField (remember to unwrap the optional)
        }))
        passwordPrompt.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
            inputTextField = textField
        })
        
        present(passwordPrompt, animated: true, completion: nil)
    }
    */
    
    func selectCampus(){
        campusRef = FIRDatabase.database().reference().child("campuses").child("san_diego")
        
        let passwordPrompt = UIAlertController(title: "Campus", message: "Select your Campus:", preferredStyle: UIAlertControllerStyle.alert)
        
        campusRef.observe(.value, with: {(snap) in
            if let userDict = snap.value as? [String:AnyObject] {
                
                AppState.sharedInstance.campusDict = userDict
                
                for each in userDict as [String: AnyObject] {
                    
                    passwordPrompt.addAction(UIAlertAction(title: each.key, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        AppState.sharedInstance.dafaultCampus = each.key
                        AppState.sharedInstance.defaultLatitude = each.value["latitude"] as? NSNumber
                        AppState.sharedInstance.defaultLongitude = each.value["longitude"] as? NSNumber
                        let notificationName = Notification.Name(rawValue: Constants.NotificationKeys.SignedIn)
                        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: nil)
                        self.performSegue(withIdentifier: Constants.Segues.SignInToFp, sender: nil)
                        
                        //self.dismiss(animated: true, completion: nil)
                    }))
                    
                }
            }
        }){ (error) in
            print(error.localizedDescription)
        }
        //DispatchQueue.main.async {
        present(passwordPrompt, animated: true, completion: nil)
        //self.dismiss(animated: true, completion: nil)
    }
    
    func checkCampus(){
        app_default = FIRDatabase.database().reference().child("app_defaults")
        app_default.observe(.value, with: {(snapshot) in
            let value = snapshot.value as? NSDictionary
            AppState.sharedInstance.showCampus = value?["show_campus"] as? Bool
            //self.showCampus =
        }){ (error) in
            print(error.localizedDescription)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //checkCampus()
        //selectCampus()
    }

    /*
    @IBAction func signupButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "SignUpIdentifier", sender: nil)
    }
    
    
    @IBAction func loginButtonClicked(_ sender: Any) {
     
        // Sign In with credentials.
        isOrgLogin = true
        
        
        if ((usernameField.text?.isEmpty)! || (passwordField.text?.isEmpty)!){
            let alert = UIAlertController(title: "Invalid Fields", message: "Enter all details", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            
            
            self.present(alert, animated: true, completion: nil)
        }
        else{

            if let email = usernameField.text, let password = passwordField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
                if error == nil {
                    self.logIn(user)
                }else{
                    print(error?.localizedDescription ?? "Something went wrong.")
                    let alert = UIAlertController(title: "Invalid User", message: "User does not exist.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    
                    return
                    }
                }
            }
        }
        
        
    }
    
    func logIn(_ user: FIRUser?) {
        if(FIRAuth.auth()?.currentUser != nil){
            
            MeasurementHelper.sendLoginEvent()
            AppState.sharedInstance.displayName = user?.displayName ?? user?.email
            AppState.sharedInstance.photoURL = user?.photoURL
            AppState.sharedInstance.signedIn = true
            let notificationName = Notification.Name(rawValue: Constants.NotificationKeys.SignedIn)
            NotificationCenter.default.post(name: notificationName, object: nil, userInfo: nil)
            performSegue(withIdentifier: Constants.Segues.SignUpToFp, sender: nil)
        }
    }
    */

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        //let viewController = segue.destination as!
        //viewController.isOrgLogin = true
        if(FIRAuth.auth()?.currentUser != nil){
            if(segue.identifier == "SignUpToFP"){
            //let barViewControllers = segue.destination as! UITabBarController
            //let nav = barViewControllers.viewControllers![0] as! UINavigationController
            
            //let destinationViewController = nav.viewControllers[0]
                let destinationViewController = segue.destination as! LiveViewController
                //destinationViewController.isOrgLogin = true
            }
        }
    }

}
