//
//  SelectSingleViewController.swift
//  Discover
//
//  Created by Sowndharya on 19/11/16.
//  Copyright © 2016 Sowndharya. All rights reserved.
//

import UIKit
import Parse

protocol SelectSingleViewControllerDelegate {
    func didSelectSingleUser(_ user: PFUser)
}

class SelectSingleViewController: UITableViewController, UISearchBarDelegate {
    
    var users = [PFUser]()
    var delegate: SelectSingleViewControllerDelegate!
    
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("INSIDE VIEWDIDLOAD OF SELECT SINGLE VIEW CONTROLLER")
        
        //self.searchBar.delegate = self
        print("CALLING LOAD USER () METHOD")
        self.loadUsers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Backend methods
    
    func loadUsers() {
        print("INSIDE LOAD USES METHOD")
        let user = PFUser.current()
        let userGeoPoint = user!["location"] as! PFGeoPoint
        let query = PFQuery(className: PF_USER_CLASS_NAME)
        query.whereKey(PF_USER_OBJECTID, notEqualTo: user!.objectId!)
        query.whereKey("location", nearGeoPoint:userGeoPoint)
        query.whereKey("wantsToTeach", equalTo: user!["wantsToLearn"]!)
        
        
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
    
    func searchUsers(_ searchLower: String) {
        let user = PFUser.current()
        let query = PFQuery(className: PF_USER_CLASS_NAME)
        query.whereKey(PF_USER_OBJECTID, notEqualTo: user!.objectId!)
        query.whereKey(PF_USER_FULLNAME_LOWER, contains: searchLower)
        query.order(byAscending: PF_USER_FULLNAME)
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                self.users.removeAll(keepingCapacity: false)
                self.users += objects as! [PFUser]!
                self.tableView.reloadData()
            } else {
                let alertController = UIAlertController(title: "Network Error", message: "\(error)", preferredStyle: UIAlertControllerStyle.alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                    print("OK")
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
            
        }
    }
    
    // MARK: - User actions
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let user = self.users[indexPath.row]
        cell.textLabel?.text = user[PF_USER_FULLNAME] as? String
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.dismiss(animated: true, completion: { () -> Void in
            if self.delegate != nil {
                self.delegate.didSelectSingleUser(self.users[indexPath.row])
            }
        })
    }
    
    // MARK: - UISearchBar Delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 0 {
            self.searchUsers(searchText.lowercased())
        } else {
            self.loadUsers()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBarCancelled()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    
    func searchBarCancelled() {
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        
        self.loadUsers()
    }
}


