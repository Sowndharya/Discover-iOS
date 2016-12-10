//
//  LoginViewController.swift
//  Discover
//
//  Created by Sowndharya on 05/11/16.
//  Copyright © 2016 Sowndharya. All rights reserved.
//

import Foundation
import UIKit
import Parse
import CoreLocation

class LoginViewController: UIViewController, UITextFieldDelegate, LocationUpdateProtocol {
    
    // MARK : Properties
    
    let LocationMgr = UserLocationManager()
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    // MARK : Actions
    
    @IBAction func login(_ sender: UIButton) {
        
        self.login()
    }
    
    
    func login() {
        
        print("Initializing location manager delegate")
        LocationMgr.delegate = self
        LocationMgr.getLocation()
    }
    
    func locationDidUpdateToLocation(location: CLLocationCoordinate2D, placemark: CLPlacemark) {
        
        print("Inside locationDidUpdate To location")
        loginForParse(location, placemark)
    }

    
    func loginForParse(_ locationCoordinates: CLLocationCoordinate2D, _ userAddress: CLPlacemark){
        
        print("login for parse")
        var email = self.emailTextField.text
        var password = self.passwordTextField.text
        
        
        // Validate the text fields
        if (email?.characters.count)! < 5  {
            
            Utilities.showAlertActionDefault(self, "Invalid", "Email must be greater than 5 characters")
            
        } else if (password?.characters.count)! < 8 {
            
            Utilities.showAlertActionDefault(self, "Invalid", "Password must be greater than 8 characters")
        } else {
            
            // Run a spinner to show a task in progress
            
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 150, height: 150))) as UIActivityIndicatorView
            spinner.startAnimating()
            
            // Send a request to login
            let point = PFGeoPoint(latitude:locationCoordinates.latitude, longitude:locationCoordinates.longitude)
            
            PFUser.logInWithUsername(inBackground: email!, password: password!, block: { (user, error) -> Void in
                
                if error == nil {
                    
                
                    print("parse login with username")
                    PushNotication.parsePushUserAssign()
                
                    // Stop the spinner
                    print(point)
                    spinner.stopAnimating()
                
                    if ((user) != nil) {
                        user?[PF_USER_LOCATION] = point
                    
                        user?[PF_USER_LOCALITY] = userAddress.locality
                        user?[PF_USER_ADMINISTRATIVE_AREA] = userAddress.administrativeArea
                        user?[PF_USER_COUNTRY] = userAddress.country
                        user?[PF_USER_POSTAL_CODE] = userAddress.postalCode
                        user?.saveInBackground()
                
                        Utilities.homeScreenLaunch(self)
                    } else {
                    
                        // Error in login
                        Utilities.showAlertActionDefault(self, "Error", (error?.localizedDescription)!)
                    }
                } else {
                    Utilities.showAlertActionDefault(self, "Error", (error?.localizedDescription)!)
                }
            })
        }

    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard)))
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if (PFUser.current() != nil) {
            
            self.dismiss(animated: true, completion: nil)
        }
        
        self.emailTextField.becomeFirstResponder()
    }

    
    func dismissKeyboard() {
        
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == self.emailTextField {
            
            self.passwordTextField.becomeFirstResponder()
            
        } else if textField == self.passwordTextField {
            
            self.login()
        }
        return true
    }

}
