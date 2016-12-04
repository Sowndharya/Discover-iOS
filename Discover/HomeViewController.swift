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
    
    var userWantsToLearn: String = ""
    var userWantsToTeach: String = ""
    
    var wantsToLearnIsEdit: Bool = true
    var wantsToTeachIsEdit: Bool = true
    
    @IBOutlet weak var welcomelabel: UILabel!
    
    @IBOutlet weak var wantsToTeachTextField: UITextField!
    
    @IBOutlet weak var wantsToLearnTextField: UITextField!
    
    // MARK : Actions
    
    
    
    
    @IBAction func wantsToLearnEditButtonClicked(_ sender: UIButton) {
        if wantsToLearnIsEdit {
            
            wantsToLearnIsEdit = false
            sender.setTitle("Done", for: UIControlState.normal)
            wantsToLearnTextField.isUserInteractionEnabled = true
            wantsToLearnTextField.becomeFirstResponder()
        }
        else {
            
            wantsToLearnIsEdit = true
            sender.setTitle("Edit", for: UIControlState.normal)
            wantsToLearnTextField.isUserInteractionEnabled = false
            userWantsToLearn = wantsToLearnTextField.text!
            wantsToLearnTextField.resignFirstResponder()
            
            let user = PFUser.current()
            user?[PF_USER_WANTS_TO_LEARN] = userWantsToLearn
            user?.saveInBackground()
        }
    }
    
    @IBAction func wantsToTeachEditButtonClicked(_ sender: UIButton) {
        
        if wantsToTeachIsEdit {
            
            wantsToTeachIsEdit = false
            sender.setTitle("Done", for: UIControlState.normal)
            wantsToTeachTextField.isUserInteractionEnabled = true
            wantsToTeachTextField.becomeFirstResponder()
        }
        else {
            
            wantsToTeachIsEdit = true
            sender.setTitle("Edit", for: UIControlState.normal)
            wantsToTeachTextField.isUserInteractionEnabled = false
            userWantsToTeach = wantsToTeachTextField.text!
            wantsToTeachTextField.resignFirstResponder()
            
            let user = PFUser.current()
            user?[PF_USER_WANTS_TO_TEACH] = userWantsToTeach
            user?.saveInBackground()
        }

    
    }
    

    
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
            
            let user = PFUser.current()

            print((user?.username)!)
            
            welcomelabel.text = "Wecome, " + (user?.username)!
            
            userWantsToLearn = user?[PF_USER_WANTS_TO_LEARN] as! String
            userWantsToTeach = user?[PF_USER_WANTS_TO_TEACH] as! String
            
            wantsToLearnTextField.text = userWantsToLearn as String?
            wantsToTeachTextField.text = userWantsToTeach as String?
        }
    }
}
