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
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
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
        usernameLabel.isHidden = true
        usernameField.isHidden = true
        passwordLabel.isHidden = true
        passwordField.isHidden = true
        loginInButton.isHidden = true
        forgetPasswordButton.isHidden = true
        signupButton.isHidden = true
        customFBButton.isHidden = false
        /* ****** TO be uncommented in final code**********
        if FIRAuth.auth()?.currentUser != nil{
            // User is signed in.
            // Move the user to the Home Screen.
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            homeViewController = mainStoryboard.instantiateViewController(withIdentifier: "TabView") as! UITabBarController
            self.perform(#selector(self.presentHomeViewController), with: nil, afterDelay: 0.0)
        }
        */
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignInViewController.hideKeyBoard))
        view.addGestureRecognizer(tap)
    
    }

    @IBAction func segmentStateChanged(_ sender: Any) {
        switch segmentView.selectedSegmentIndex{
        case 0:
            usernameLabel.isHidden = true
            usernameField.isHidden = true
            passwordLabel.isHidden = true
            passwordField.isHidden = true
            loginInButton.isHidden = true
            forgetPasswordButton.isHidden = true
            signupButton.isHidden = true
            customFBButton.isHidden = false
        case 1:
            usernameLabel.isHidden = false
            usernameField.isHidden = false
            passwordLabel.isHidden = false
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
            guard let email = usernameField.text, let password = passwordField.text else { return }
            FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
                if let error = error {
                    //                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    //                    self.viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginView") as UIViewController
                    //                    //self.present(homeViewController, animated: true, completion: nil)
                    //                    //self.navigationController?.show(homeViewController, sender: nil)
                    //                    self.perform(#selector(self.presentViewController1), with: nil, afterDelay: 0.0)
                    print(error.localizedDescription)
                    return
                }
                self.signedIn(user!)
            }
        }
    }
    
   // @IBOutlet weak var signupButtonClicked: UIButton!
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
