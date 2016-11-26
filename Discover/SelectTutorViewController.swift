//
//  SelectTutorViewController.swift
//  Discover
//
//  Created by Rizwan Ahmed on 26/11/16.
//  Copyright © 2016 Sowndharya. All rights reserved.
//

import UIKit
import Parse

protocol SelectTutorViewControllerDelegate {
    func didSelectTutor(_ user:PFUser)
}

class SelectTutorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var distanceLabelView: UILabel!
    @IBOutlet weak var distanceSliderView: UISlider!
    
    
    var distanceValue: Int = 1
    var users = [PFUser]()
    var delegate: SelectTutorViewControllerDelegate!
    let cellReuseIdentifier = "tutorCell"
    
    
    @IBAction func sliderValueDidChange(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        
        if currentValue == 1 {
            self.distanceLabelView.text = "\(currentValue) km"
        } else {
            self.distanceLabelView.text = "\(currentValue) kms"
            
        }
        distanceValue = currentValue
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
        self.loadUsers()
    }
    // MARK: - Backend methods
    
    func loadUsers() {
        print("INSIDE LOAD USES METHOD")
        let user = PFUser.current()
        let userWantsToLearn = user?[PF_USER_WANTS_TO_LEARN]
        let userGeoPoint = user![PF_USER_LOCATION] as! PFGeoPoint
        

        let query = PFQuery(className: PF_USER_CLASS_NAME)
        
        query.whereKey(PF_USER_OBJECTID, notEqualTo: user!.objectId!)
        query.whereKey(PF_USER_LOCATION, nearGeoPoint:userGeoPoint)
        query.whereKey(PF_USER_WANTS_TO_TEACH, equalTo: userWantsToLearn!)
        
        query.order(byAscending: PF_USER_FULLNAME)
        query.limit = 1000
        
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                print("RETRIEVING USERS")
                self.users.removeAll(keepingCapacity: false)
                if let array = objects as? [PFUser] {
                    for obj in array {
                        if ((obj as PFUser)[PF_USER_FULLNAME] as? String) != nil {
                            print(PF_USER_FULLNAME)
                            self.users.append(obj as PFUser)
                        }
                    }
                }
                
                self.tableView.reloadData()
                
            } else {
                print("NETWORK ERROR")
                let alertController = UIAlertController(title: "Error", message: "\(error)", preferredStyle: UIAlertControllerStyle.alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                    print("OK")
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
            
        }
    }

    @IBAction func onCancelButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        // set the text from the data model
        let user = self.users[indexPath.row]
        cell.textLabel?.text = user[PF_USER_FULLNAME] as? String
        
        return cell
    }
    
    // method to run when table view cell is tapped
    
    // MARK: - Table view delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: { () -> Void in
            if self.delegate != nil {
                self.delegate.didSelectTutor(self.users[indexPath.row])
            }
        })
    }
}
