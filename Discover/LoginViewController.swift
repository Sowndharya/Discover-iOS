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

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK : Properties
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK : Actions
    
    @IBAction func login(_ sender: UIButton) {
        print("LOGIN VIEW CONTROLLER --- " + "ILOGIN BUTTON PRESSED")
        
        self.login()
        
    }
    
    func login() {
        print("LOGIN VIEW CONTROLLER --- " + "INSIDE LOGIN METHOD")
        var email = self.emailTextField.text
        var password = self.passwordTextField.text
        // Validate the text fields
        if (email?.characters.count)! < 5 {
            print("LOGIN VIEW CONTROLLER --- " + "ALERT MESSAGE FOR EMAIL")
            
            let alertController = UIAlertController(title: "Invalid", message: "Email must be greater than 5 characters", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                print("OK")
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
            
        } else if (password?.characters.count)! < 8 {
            
            print("LOGIN VIEW CONTROLLER --- " + "ALERT MESSAGE FOR PASSWORD")
            let alertController = UIAlertController(title: "Invalid", message: "Password must be greater than 8 characters", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                print("OK")
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
            
            
        } else {
            
            print("LOGIN VIEW CONTROLLER --- " + "ASPINNER FOR LOGIN")
            
            // Run a spinner to show a task in progress
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 150, height: 150))) as UIActivityIndicatorView
            spinner.startAnimating()
            
            // Send a request to login
            PFUser.logInWithUsername(inBackground: email!, password: password!, block: { (user, error) -> Void in
                
                PushNotication.parsePushUserAssign()
                
                // Stop the spinner
                spinner.stopAnimating()
                
                if ((user) != nil) {
                    print("LOGIN VIEW CONTROLLER --- " + "LOGIN SUCCESS")
                    
                    
                
                    
                    self.dismiss(animated: true, completion: nil)
                    
//                    DispatchQueue.main.async { () -> Void in
//                        print("LOGIN VIEW CONTROLLER --- " + "INITIATE HOME VIEW CONTROLLER")
//                        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController")
//                        self.present(viewController, animated: true, completion: nil)
//                    }
                    
                    
                    
                } else {
                    let alertController = UIAlertController(title: "Error", message: "\(error)", preferredStyle: UIAlertControllerStyle.alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                        print("OK")
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    
                }
            })
        }

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("LOGIN VIEW CONTROLLER --- " + "INSID VIEW DID LOAD")
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard)))
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (PFUser.current() != nil) {
            self.dismiss(animated: true, completion: nil)

            
        } 

        print("LOGIN VIEW CONTROLLER --- " + "INSIDE VIEW DID APPEAR")
        self.emailTextField.becomeFirstResponder()
    }

    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
