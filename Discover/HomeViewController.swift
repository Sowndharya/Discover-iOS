//
//  HomeViewController.swift
//  Discover
//
//  Created by Sowndharya on 05/11/16.
//  Copyright © 2016 Sowndharya. All rights reserved.
//

import UIKit
import Parse

class HomeViewController: UIViewController, UITextFieldDelegate {
    
    // MARK : Properties
    
    
    var userWantsToLearn : String = ""
    var userWantsToteach : String = ""
    
    @IBOutlet weak var welcomelabel: UILabel!
    
    
    @IBOutlet weak var wantsToTeachTextField: UITextField!
    
    @IBOutlet weak var wantsToLearnTextField: UITextField!
    
    // MARK : Actions
    
    @IBAction func logoutAction(_ sender: UIButton) {
        
        // Send a request to log out a user
        PFUser.logOut()
        
        PushNotication.parsePushUserResign()
        Utilities.postNotification(NOTIFICATION_USER_LOGGED_OUT)
        Utilities.loginUser(self)
    }
    
    @IBAction func viewMessagesAction(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "viewMessagesSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let backItem = UIBarButtonItem()
        backItem.title = "Home"
        navigationItem.backBarButtonItem = backItem
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if (PFUser.current() == nil) {
            
            Utilities.loginUser(self)
            
        } else {
            
            print((PFUser.current()?.username)!)
            
            userWantsToLearn = PFUser.current()?[PF_USER_WANTS_TO_LEARN] as! String
            userWantsToteach = PFUser.current()?[PF_USER_WANTS_TO_TEACH] as! String
            
            wantsToLearnTextField.text = userWantsToLearn as String?
            wantsToTeachTextField.text = userWantsToteach as String?
        }
    }
}
