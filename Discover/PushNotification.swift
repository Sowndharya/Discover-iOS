//
//  PushNotification.swift
//  Discover
//
//  Created by Sowndharya on 19/11/16.
//  Copyright © 2016 Sowndharya. All rights reserved.
//

import Foundation
import Parse

class PushNotication {
    
    class func parsePushUserAssign() {
        let installation = PFInstallation.current()
        installation?[PF_INSTALLATION_USER] = PFUser.current()
        installation?.saveInBackground { (succeeded: Bool, error: Error?) -> Void in
            if error != nil {
                print("parsePushUserAssign save error.")
            }
        }
    }
    
    class func parsePushUserResign() {
        let installation = PFInstallation.current()
        installation?.remove(forKey: PF_INSTALLATION_USER)
        installation?.saveInBackground { (succeeded: Bool, error: Error?) -> Void in
            if error != nil {
                print("parsePushUserResign save error")
            }
        }
    }
    
    class func sendPushNotification(_ groupId: String, text: String) {
        let query = PFQuery(className: PF_MESSAGES_CLASS_NAME)
        query.whereKey(PF_MESSAGES_GROUPID, equalTo: groupId)
        query.whereKey(PF_MESSAGES_USER, equalTo: PFUser.current()!)
        query.includeKey(PF_MESSAGES_USER)
        query.limit = 1000
        
        let installationQuery = PFInstallation.query()
        installationQuery!.whereKey(PF_INSTALLATION_USER, matchesKey: PF_MESSAGES_USER, in: query)
        
        let push = PFPush()
        push.setQuery(installationQuery as! PFQuery<PFInstallation>?)
        push.setMessage(text)
        push.sendInBackground { (succeeded: Bool, error: Error?) -> Void in
            if error != nil {
                print("sendPushNotification error")
            }
        }
    }
    
}
