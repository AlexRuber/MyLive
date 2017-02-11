//
//  AddEventViewController.swift
//  CampusLive
//
//  Created by Raghav Nyati on 2/10/17.
//  Copyright © 2017 Mihai Ruber. All rights reserved.
//

import UIKit
import MapKit

class AddEventViewController: UIViewController {

    var location: CLLocation!
    
    //Post Button
    @IBAction func didTapPost(_ sender: Any) {
    
        
        let addEventPopup = UIAlertController(title: "✔️️", message: "Your event was succesfully posted", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Close", style: .default, handler: nil)
        addEventPopup.addAction(defaultAction)
        present(addEventPopup, animated: true, completion: nil)
        
   
    
        
    }
    
    
    //Back Button 
    @IBAction func BackBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Add event View did load called.")
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}
