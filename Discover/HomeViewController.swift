//
//  HomeViewController.swift
//  Discover
//
//  Created by Sowndharya on 05/11/16.
//  Copyright © 2016 Sowndharya. All rights reserved.
//

import UIKit
import Parse

class HomeViewController: UIViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var distanceValueLabel: UILabel!

    var distanceValue: Int = 1
    
    //MARK: Actions
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        
        let currentValue = Int(sender.value)
        
        distanceValueLabel.text = "\(currentValue)"
        distanceValue = currentValue
    }
    

    @IBAction func viewTutors(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "viewTutorsSegue", sender: self)
    }
    @IBAction func logoutAction(_ sender: UIButton) {
        // Send a request to log out a user
        
        PFUser.logOut()
        
        PushNotication.parsePushUserResign()
        Utilities.postNotification(NOTIFICATION_USER_LOGGED_OUT)
        Utilities.loginUser(self)
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if (PFUser.current() == nil) {
            
            Utilities.loginUser(self)
            
        } else {
            print("HOME VIEW CONTROLLER --- " +  "CURRENT USER IS " + (PFUser.current()?.username)!)
        }
    }

}
