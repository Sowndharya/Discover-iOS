//
//  SignupViewController.swift
//  Discover
//
//  Created by Sowndharya on 05/11/16.
//  Copyright © 2016 Sowndharya. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Parse

class SignupViewController: UIViewController, UITextFieldDelegate, LocationUpdateProtocol {
    
    // MARK : Properties
    
    let LocationMgr = UserLocationManager()
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var wantsToLearnTextField: UITextField!
    @IBOutlet weak var wantsToTeachTextField: UITextField!
    

    // MARK : Actions
    
    @IBAction func login(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "loginViewSegue", sender: self)
    }
    
    @IBAction func signup(_ sender: UIButton) {
        self.signup()
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SignupViewController.dismissKeyboard)))
        
        self.usernameTextField.delegate = self
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.wantsToLearnTextField.delegate = self
        self.wantsToTeachTextField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        self.usernameTextField.becomeFirstResponder()
    }
    
    func dismissKeyboard() {
        
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == self.usernameTextField {
            self.emailTextField.becomeFirstResponder()
        } else if textField == self.emailTextField {
            self.passwordTextField.becomeFirstResponder()
        } else if textField == self.passwordTextField {
            self.wantsToLearnTextField.becomeFirstResponder()
        } else if textField == self.wantsToLearnTextField {
           self.wantsToTeachTextField.becomeFirstResponder()
        }else if textField == self.wantsToTeachTextField {
            //self.getLocation()
           self.signup()
        }
        return true
    }
    
    
    func signup() {
        
        print("initializing location manager. shared manager")
        print("Initializing location manager delegate")
        LocationMgr.delegate = self
        LocationMgr.getLocation()
    }
    
    func locationDidUpdateToLocation(location: CLLocationCoordinate2D, placemark: CLPlacemark) {
        
        print("Inside locationDidUpdate To location")
        signupForParse(location, placemark)
    }
    
    
    
    func signupForParse(_ locationCoordinates: CLLocationCoordinate2D, _ userAddress: CLPlacemark) {
        
        let username = self.usernameTextField.text
        let password = self.passwordTextField.text
        let wantsToLearn = self.wantsToLearnTextField.text
        let wantsToTeach = self.wantsToTeachTextField.text
        let email = self.emailTextField.text
        let finalEmail = email?.trimmingCharacters(in: NSCharacterSet.whitespaces)
        
        // Validate the text fields
        if (username?.characters.count)! < 5 {
            
            Utilities.showAlertActionDefault(self, "Invalid", "Username must be greater than 5 characters")
            
        } else if (password?.characters.count)! < 8 {
            
            Utilities.showAlertActionDefault(self, "Invalid", "Password must be greater than 8 characters")
        
        } else if !(Utilities.validateEmail(candidate: email!)) {
            
            Utilities.showAlertActionDefault(self, "Invalid", "Please enter a valid email")
            
        } else {
            
            // Run a spinner to show a task in progress
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 150, height: 150))) as UIActivityIndicatorView
            spinner.startAnimating()
            
            
            
            let newUser = PFUser()
            newUser.username = username
            newUser.password = password
            newUser.email = finalEmail
            newUser[PF_USER_WANTS_TO_LEARN] = wantsToLearn
            newUser[PF_USER_WANTS_TO_TEACH] = wantsToTeach
            newUser[PF_USER_FULLNAME] = username
            newUser[PF_USER_FULLNAME_LOWER] = username?.lowercased()
            newUser[PF_USER_EMAILCOPY] = finalEmail
            
            let point = PFGeoPoint(latitude: locationCoordinates.latitude, longitude:locationCoordinates.longitude)
            newUser[PF_USER_LOCATION] = point
            
            newUser[PF_USER_LOCALITY] = userAddress.locality
            newUser[PF_USER_ADMINISTRATIVE_AREA] = userAddress.administrativeArea
            newUser[PF_USER_COUNTRY] = userAddress.country
            newUser[PF_USER_POSTAL_CODE] = userAddress.postalCode
            
            // Sign up the user asynchronously
            newUser.signUpInBackground(block: { (succeed, error) -> Void in
                if error == nil {
                    
                    print("Inside signup in background")
                    // Stop the spinner
                    spinner.stopAnimating()
                    Utilities.homeScreenLaunch(self)

                    
                } else {
                    
                    
                    Utilities.showAlertActionDefault(self, "Error", (error?.localizedDescription)!)
                    print((error?.localizedDescription)!)
                    //PushNotication.parsePushUserAssign()
                }
            })
        }
    }
    
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
