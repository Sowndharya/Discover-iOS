//
//  MessagesCell.swift
//  Discover
//
//  Created by Sowndharya on 19/11/16.
//  Copyright © 2016 Sowndharya. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import JSQMessagesViewController

class MessagesCell: UITableViewCell {
    
    @IBOutlet var userImage: PFImageView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var lastMessageLabel: UILabel!
    @IBOutlet var timeElapsedLabel: UILabel!
    //@IBOutlet var counterLabel: UILabel!
    
    func bindData(_ message: PFObject) {
        userImage.layer.cornerRadius = userImage.frame.size.width / 2
        userImage.layer.masksToBounds = true
        
        //let lastUser = message[PF_MESSAGES_LASTUSER] as? PFUser
        //userImage.file = lastUser?[PF_USER_PICTURE] as? PFFile
        userImage.image = UIImage(named: "profile_blank")
        userImage.loadInBackground()
        
        descriptionLabel.text = message[PF_MESSAGES_DESCRIPTION] as? String
        lastMessageLabel.text = message[PF_MESSAGES_LASTMESSAGE] as? String
        
        let seconds = Date().timeIntervalSince((message[PF_MESSAGES_UPDATEDACTION] as! NSDate) as Date)
        timeElapsedLabel.text = Utilities.timeElapsed(seconds)
        let dateText = JSQMessagesTimestampFormatter.shared().relativeDate(for: message[PF_MESSAGES_UPDATEDACTION] as? NSDate as Date!)
        if dateText == "Today" {
            timeElapsedLabel.text = JSQMessagesTimestampFormatter.shared().time(for: message[PF_MESSAGES_UPDATEDACTION] as? NSDate as Date!)
        } else {
            timeElapsedLabel.text = dateText
        }
        
        //let counter = (message[PF_MESSAGES_COUNTER]! as AnyObject).integerValue
        //counterLabel.text = (counter == 0) ? "" : "\(counter) new"
    }
    
}
