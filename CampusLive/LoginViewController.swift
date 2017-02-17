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

class SignInViewController: UIViewController {

    var homeViewController: UIViewController!
    var viewController: UIViewController!
    //var signupViewController: UIViewController!
    

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginInButton: UIButton!
    @IBOutlet weak var forgetPasswordButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var segmentView: UISegmentedControl!
    @IBOutlet weak var customFBButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        customFBButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
        
        segmentView.selectedSegmentIndex = 0
        usernameField.isHidden = true
        passwordField.isHidden = true
        loginInButton.isHidden = true
        forgetPasswordButton.isHidden = true
        signupButton.isHidden = true
        customFBButton.isHidden = false
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignInViewController.hideKeyBoard))
        view.addGestureRecognizer(tap)
    
    }

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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hideKeyBoard(){
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*
        if let user = FIRAuth.auth()?.currentUser {
            self.signedIn(user)
        }
        */
    }
    
    func presentHomeViewController(){
        self.present(homeViewController, animated: true, completion: nil)
    }
    
    func presentViewController1(){
        self.present(viewController, animated: true, completion: nil)
    }
    
    func handleCustomFBLogin(){
        //print(1234)
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile", "user_friends"], from: self){ (result, err) in
            if(err != nil){
                print("Fb Login Failed", err ?? "")
                return
            }
            print(result?.token.tokenString ?? "")
            self.showEmailAddress()
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
            self.signedIn(user)
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
    
    func signedIn(_ user: FIRUser?) {
        MeasurementHelper.sendLoginEvent()
        
        AppState.sharedInstance.displayName = user?.displayName ?? user?.email
        AppState.sharedInstance.photoURL = user?.photoURL
        AppState.sharedInstance.signedIn = true
        let notificationName = Notification.Name(rawValue: Constants.NotificationKeys.SignedIn)
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: nil)
        performSegue(withIdentifier: Constants.Segues.SignInToFp, sender: nil)
    }

    
    @IBAction func signupButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "SignUpIdentifier", sender: nil)
    }
    
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        // Sign In with credentials.
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
                destinationViewController.isOrgLogin = true
            }
        }
    }

}
