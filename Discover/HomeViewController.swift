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
        
        print("HOME VIEW CONTROLLER --- " + "SLIDER VALUE CHANGED")
        let currentValue = Int(sender.value)
        
        distanceValueLabel.text = "\(currentValue)"
        distanceValue = currentValue
    }
    
//    
//    @IBAction func viewMessages(_ sender: UIButton) {
//        
//        print("HOME VIEW CONTROLLER --- " + "VIEW MESSAGES BUTTON CLICKED")
//        DispatchQueue.main.async { () -> Void in
//            print("HOME VIEW CONTROLLER --- " + "INITIATING THE MESSAGES VIEW CONTROLLER")
//            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MessagesViewController");
//            self.present(viewController, animated: true, completion: nil)
//        }
//
//    }

    @IBAction func logoutAction(_ sender: UIButton) {
        // Send a request to log out a user
        print("HOME VIEW CONTROLLER --- " + "LOGOUT BUTTON CLICKED")
        print("HOME VIEW CONTROLLER --- " + "LOGGING OUT")
        PFUser.logOut()
        print("HOME VIEW CONTROLLER --- " + "CALLING PUSH.parsepushUserResign")
        PushNotication.parsePushUserResign()
        Utilities.postNotification(NOTIFICATION_USER_LOGGED_OUT)
        Utilities.loginUser(self)
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
//    @IBAction func ViewTutorsAction(_ sender: UIButton) {
//        self.performSegue(withIdentifier: "viewTutorsSegue", sender: distanceValue)
//    
//    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let backItem = UIBarButtonItem()
//        backItem.title = "Back"
//        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("HOME VIEW CONTROLLER --- " + "VIEW WILL APPEAR")
        if (PFUser.current() == nil) {
            
                print("HOME VIEW CONTROLLER --- " + "CURRENT USER IS NIL")
                 Utilities.loginUser(self)
            
        } else {
            print("HOME VIEW CONTROLLER --- " +  "CURRENT USER IS " + (PFUser.current()?.username)!)
        }
    }

}
