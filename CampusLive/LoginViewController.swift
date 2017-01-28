//
//  SignInViewController.swift
//  CampusLive
//
//  Created by Raghav Nyati on 1/23/17.
//  Copyright © 2017 Mihai Ruber. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth

class SignInViewController: UIViewController, FBSDKLoginButtonDelegate {

    var viewController: UIViewController!
    var loginButton = FBSDKLoginButton()
    var homeViewController: UIViewController!
    
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var forgetPassword: UIButton!
    @IBOutlet weak var orgLoginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var segmentView: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton.isHidden = false
        usernameLabel.isHidden = true
        usernameTextField.isHidden = true
        passwordLabel.isHidden = true
        passwordTextField.isHidden = true
        orgLoginButton.isHidden = true
        forgetPassword.isHidden = true
        signUpButton.isHidden = true
        
        if FIRAuth.auth()?.currentUser != nil {
            // User is signed in.
            // Move the user to the Home Screen
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            homeViewController = mainStoryboard.instantiateViewController(withIdentifier: "TabView") as! UITabBarController
            self.perform(#selector(self.presentHomeViewController), with: nil, afterDelay: 0.0)
            
        } else {
            // No user is signed in.
            // Show the user the Login Button
            self.loginButton.center = self.view.center
            self.loginButton.readPermissions = ["public_profile", "email", "user_friends"]
            self.loginButton.delegate = self
            self.view.addSubview(loginButton)
            self.loginButton.isHidden = false
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignInViewController.hideKeyBoard))
        view.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view.
    }

    @IBAction func segmentStateChanged(_ sender: Any) {
        switch segmentView.selectedSegmentIndex{
        case 0:
           // reloadData()
            loginButton.isHidden = false
            usernameLabel.isHidden = true
            usernameTextField.isHidden = true
            passwordLabel.isHidden = true
            passwordTextField.isHidden = true
            orgLoginButton.isHidden = true
            forgetPassword.isHidden = true
            signUpButton.isHidden = true
        case 1:
           // reloadData()
            loginButton.isHidden = true
            usernameLabel.isHidden = false
            usernameTextField.isHidden = false
            passwordLabel.isHidden = false
            passwordTextField.isHidden = false
            orgLoginButton.isHidden = false
            forgetPassword.isHidden = false
            signUpButton.isHidden = false
        default:
            break;
        }
    }
    
    func hideKeyBoard(){
        view.endEditing(true)
    }
    
    func presentHomeViewController(){
        self.present(homeViewController, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let user = FIRAuth.auth()?.currentUser {
            self.signedIn(user)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        print("user logged in.")
        
        loginButton.isHidden = true
        //aivLoadingSpinner.startAnimating()
        
        if error != nil {
            print("**** Firebase Auth ERROR ****")
            //print(error!)
            self.loginButton.isHidden = false
            //aivLoadingSpinner.stopAnimating()
        }
        else if(result.isCancelled){
            self.loginButton.isHidden = false
            //aivLoadingSpinner.stopAnimating()
        }
        else{
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                print("Usr logged in to Fireabse Auth.")
                //self.aivLoadingSpinner.stopAnimating()
                self.signedIn(user)
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("user logged out.")
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
    
    func setDisplayName(_ user: FIRUser) {
        let changeRequest = user.profileChangeRequest()
        changeRequest.displayName = user.email!.components(separatedBy: "@")[0]
        changeRequest.commitChanges(){ (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.signedIn(FIRAuth.auth()?.currentUser)
        }
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
