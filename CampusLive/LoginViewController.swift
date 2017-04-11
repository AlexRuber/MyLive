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

class SignInViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {

    var homeViewController: UIViewController!
    var viewController: UIViewController!
    //var signupViewController: UIViewController!

    var users: FIRDatabaseReference!
    var app_default: FIRDatabaseReference!
    var campusRef: FIRDatabaseReference!
    
    //var isOrgLogin: Bool = false
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var policyLabel: UILabel!
    @IBOutlet weak var policyButton: UIButton!

    @IBOutlet weak var loginBackgroundImage: UIImageView!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var featureScrollView: UIScrollView!
    @IBOutlet weak var featurePageControl: UIPageControl!
    @IBOutlet weak var customFBButton: UIButton!
    
    var featureImagesArray = [UIImage]()
    var titleArray = ["See what's happening around you...", "Keep up to date with your college campus...", "Discover San Diego"]
    
    @IBAction func didTapTerms(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "http://www.myliveinc.com")! as URL)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (FBSDKAccessToken.current() != nil && FIRAuth.auth()?.currentUser != nil)
        {
            showEmailAddress()
            
            let blueColor = UIColor(red: 31.0/255.0, green: 150.0/255.0, blue: 254.0/255.0, alpha: 1.0)
            loginBackgroundImage.isHidden = true
            featureScrollView.isHidden = true
            customFBButton.isHidden = true
            featurePageControl.isHidden = true
            titleLabel.isHidden = true
            policyButton.isHidden = true
            policyLabel.isHidden = true
            
            let image = UIImage(named: "High Res Logo (Square)")
            let imageView = UIImageView(image: image!)
            
            imageView.frame = CGRect(x: 110, y: 109, width: 154, height: 154)
            imageView.isOpaque = true
            view.addSubview(imageView)

            _ = UIColor(red: 26/255.0, green: 127/255.0, blue: 254/255.0, alpha: 1.0)
            self.view.backgroundColor = blueColor
            self.view.tintColor = blueColor
            
        }
        
        UIApplication.shared.statusBarStyle = .default
        
        users = FIRDatabase.database().reference().child("users")
        
        //Custom FB Button Settings
        let customFBImage = UIImage(named: "facebook-login-blue")
        customFBButton.setImage(customFBImage, for: .normal)
        customFBButton.frame = CGRect(x: 32, y: 320
            , width: 300, height: 532)
        customFBButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
  
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
    
    override func viewWillAppear(_ animated: Bool) {
    }
    override func viewDidAppear(_ animated: Bool) {
        
        var _: CGFloat = 0.0
        
        featureImagesArray = [#imageLiteral(resourceName: "Log In 1"), #imageLiteral(resourceName: "Log In 2"), #imageLiteral(resourceName: "Log In 3")]
        featureScrollView.isPagingEnabled = true
        
        featureScrollView.showsHorizontalScrollIndicator = false
        
        loadFeatures()
        titleLabel.text = titleArray[0]
        
        featureScrollView.delegate = self
    }
    
    func loadFeatures() {
        
        let scrollWidth = featureScrollView.frame.size.width
        var index = 0
        titleLabel.text = titleArray[0]
        for feature in featureImagesArray {
        
            let featureImageView = UIImageView(image: feature)
            featureImageView.contentMode = .scaleAspectFit
            featureScrollView.addSubview(featureImageView)
            
            featureImageView.frame = CGRect(x: (featureScrollView.frame.origin.x - 67) + (featureScrollView.frame.size.width * CGFloat(index)), y: featureScrollView.frame.origin.y - 141, width: scrollWidth, height: featureScrollView.frame.size.height)
            
            index = index + 1
        }
        
        featureScrollView.contentSize = CGSize(width: featureScrollView.frame.origin.x + scrollWidth * CGFloat(featureImagesArray.count), height: 241)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        featurePageControl.currentPage = Int(page)
        if(featurePageControl.currentPage == 0){
            titleLabel.text = titleArray[0]
        }else if(featurePageControl.currentPage == 1){
            titleLabel.text = titleArray[1]
        }else{
            titleLabel.text = titleArray[2]
        }
    }
  
    //Check access token for already logged facebook
    
    func presentHomeViewController(){
        self.present(homeViewController, animated: true, completion: nil)
    }
    
    func presentViewController1(){
        self.present(viewController, animated: true, completion: nil)
    }
    
    func handleCustomFBLogin(){
        self.customFBButton.isHidden = false
        
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile", "user_friends"], from: self){ (result, err) in
            if(err != nil){
                print("Fb Login Failed", err ?? "")
                self.dismiss(animated: true, completion: nil)
            }
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
            
            let currentDate = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "yyyy-MM-dd h:mm a"
            let newDate = dateFormatter.string(from: currentDate)
            
            let userData: [String : AnyObject] = ["provider": user?.providerID as AnyObject, "createdOn": newDate as AnyObject]
            self.signedIn(user, userID: (user?.uid)!, userData: userData as! Dictionary<String, String>)
        })
        
    }
    
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
    }
    
    func selectCampus(){
        campusRef = FIRDatabase.database().reference().child("campuses").child("san_diego")
        campusRef.observe(.value
            , with: {(snap) in
            if let userDict = snap.value as? [String:AnyObject] {
                
                AppState.sharedInstance.campusDict = userDict
                for each in userDict as [String: AnyObject] {
                    
                        AppState.sharedInstance.dafaultCampus = each.key
                        AppState.sharedInstance.defaultLatitude = each.value["latitude"] as? NSNumber
                        AppState.sharedInstance.defaultLongitude = each.value["longitude"] as? NSNumber
                        let notificationName = Notification.Name(rawValue: Constants.NotificationKeys.SignedIn)
                        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: nil)
                        self.performSegue(withIdentifier: Constants.Segues.SignInToFp, sender: nil)
                    
                }
            }
        }){ (error) in
            print(error.localizedDescription)
        }
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(FIRAuth.auth()?.currentUser != nil){
            if(segue.identifier == "SignUpToFP"){
                _ = segue.destination as! LiveViewController
            }
        }
    }

}
