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

class SignupViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    // MARK : Properties
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var wantsToLearnTextField: UITextField!
    @IBOutlet weak var wantsToTeachTextField: UITextField!
    
    let locationManager = CLLocationManager()
    var locationLat:Double = 0.0
    var locationLon:Double = 0.0

    
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
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
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
            
            self.signup()
        }
        return true
    }
    
    func getLocation() {
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func signup() {
        
        self.getLocation()
        
        let username = self.usernameTextField.text
        let password = self.passwordTextField.text
        let wantsToLearn = self.wantsToLearnTextField.text
        let wantsToTeach = self.wantsToTeachTextField.text
        var email = self.emailTextField.text
        let finalEmail = email?.trimmingCharacters(in: NSCharacterSet.whitespaces)
        
        // Validate the text fields
        if (username?.characters.count)! < 5 {
            
            let alertController = UIAlertController(title: "Invalid", message: "Username must be greater than 5 characters", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                print("OK")
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
        } else if (password?.characters.count)! < 8 {
            
            let alertController = UIAlertController(title: "Invalid", message: "Password must be greater than 8 characters", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                print("OK")
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
            
            
        } else if (email?.characters.count)! < 8 {
            
            let alertController = UIAlertController(title: "Invalid", message: "Please enter a valid email address", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                print("OK")
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
            
        } else {
            
            // Run a spinner to show a task in progress
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 150, height: 150))) as UIActivityIndicatorView
            spinner.startAnimating()
            
            let point = PFGeoPoint(latitude:locationLat, longitude:locationLon)
            locationManager.stopUpdatingLocation()
            
            let newUser = PFUser()
            newUser.username = username
            newUser.password = password
            newUser.email = finalEmail
            newUser[PF_USER_WANTS_TO_LEARN] = wantsToLearn
            newUser[PF_USER_WANTS_TO_TEACH] = wantsToTeach
            newUser[PF_USER_LOCATION] = point
            newUser[PF_USER_FULLNAME] = username
            newUser[PF_USER_FULLNAME_LOWER] = username?.lowercased()
            newUser[PF_USER_EMAILCOPY] = finalEmail
            
            // Sign up the user asynchronously
            newUser.signUpInBackground(block: { (succeed, error) -> Void in
                
                // Stop the spinner
                spinner.stopAnimating()
                if ((error) != nil) {
                    
                    PushNotication.parsePushUserAssign()
                    let alertController = UIAlertController(title: "Error", message: "\(error)", preferredStyle: UIAlertControllerStyle.alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                        print("OK")
                    }
                    
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    
                } else {
                    
                    self.dismiss(animated: true, completion: nil)
                }
                
            })
            
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        locationLat = locValue.latitude
        locationLon = locValue.latitude
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        let alertController = UIAlertController(title: "Location Error", message: "\(error)", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            print("OK")
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        
        
        
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}
