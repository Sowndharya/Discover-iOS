//
//  HomeViewController.swift
//  Discover
//
//  Created by Sowndharya on 05/11/16.
//  Copyright © 2016 Sowndharya. All rights reserved.
//

import UIKit
import Parse

class HomeViewController: UIViewController, UITextFieldDelegate, LocationUpdateProtocol {
    
    // MARK : Properties
    
    var userWantsToLearn: String = ""
    var userWantsToTeach: String = ""
    var userLocation: String = ""
    
    var wantsToLearnIsEdit: Bool = true
    var wantsToTeachIsEdit: Bool = true
    
    let LocationMgr = UserLocationManager()
    
    @IBOutlet weak var welcomelabel: UILabel!
    
    @IBOutlet weak var wantsToTeachTextField: UITextField!
    @IBOutlet weak var wantsToLearnTextField: UITextField!
    
    @IBOutlet weak var userLocationTextField: UITextView!
    
    // MARK : Actions
    
    @IBAction func wantsToLearnEditButtonClicked(_ sender: UIButton) {
        
        if wantsToLearnIsEdit {
            
            wantsToLearnIsEdit = false
            sender.setTitle("Done", for: UIControlState.normal)
            makeEditable(textField: wantsToLearnTextField)
            
        } else {
            
            wantsToLearnIsEdit = true
            sender.setTitle("Edit", for: UIControlState.normal)
            doneEditing(textField: wantsToLearnTextField)
            
            userWantsToLearn = wantsToLearnTextField.text!
            let user = PFUser.current()
            user?[PF_USER_WANTS_TO_LEARN] = userWantsToLearn
            user?.saveInBackground()
        }
    }
    
    @IBAction func wantsToTeachEditButtonClicked(_ sender: UIButton) {
        
        if wantsToTeachIsEdit {
            
            wantsToTeachIsEdit = false
            sender.setTitle("Done", for: UIControlState.normal)
            makeEditable(textField: wantsToTeachTextField)
       
        } else {
            
            wantsToTeachIsEdit = true
            sender.setTitle("Edit", for: UIControlState.normal)
            doneEditing(textField: wantsToTeachTextField)
            
            userWantsToTeach = wantsToTeachTextField.text!
            let user = PFUser.current()
            user?[PF_USER_WANTS_TO_TEACH] = userWantsToTeach
            user?.saveInBackground()
        }
    }
    
    func makeEditable(textField: UITextField) {
        textField.isUserInteractionEnabled = true
        textField.becomeFirstResponder()
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
    }
    
    func doneEditing(textField: UITextField) {
        textField.isUserInteractionEnabled = false
        textField.becomeFirstResponder()
    }
    

    @IBAction func locationUpdate(_ sender: UIButton) {
        
        LocationMgr.delegate = self
        LocationMgr.getLocation()
    }
    
    func locationDidUpdateToLocation(location: CLLocationCoordinate2D, placemark: CLPlacemark) {
        
        updateUserLocation(location, placemark)
    }
    
    func updateUserLocation(_ locationCoordinates: CLLocationCoordinate2D, _ userAddress: CLPlacemark) {
        
        let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 150, height: 150))) as UIActivityIndicatorView
        spinner.startAnimating()
        
        let user = PFUser.current()
        let point = PFGeoPoint(latitude:locationCoordinates.latitude, longitude:locationCoordinates.longitude)
        
        user?[PF_USER_LOCATION] = point
        user?[PF_USER_LOCALITY] = userAddress.locality
        user?[PF_USER_ADMINISTRATIVE_AREA] = userAddress.administrativeArea
        user?[PF_USER_COUNTRY] = userAddress.country
        user?[PF_USER_POSTAL_CODE] = userAddress.postalCode
        user?.saveInBackground()
        
        spinner.stopAnimating()
    }
    
    @IBAction func logoutAction(_ sender: UIButton) {
        
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
            userLocation = (user?[PF_USER_LOCALITY] as! String) + " " + (user?[PF_USER_ADMINISTRATIVE_AREA] as! String) + " " + (user?[PF_USER_COUNTRY] as! String)
            
            wantsToLearnTextField.text = userWantsToLearn as String?
            wantsToTeachTextField.text = userWantsToTeach as String?
            userLocationTextField.text = userLocation
        }
    }
}
