//
//  ChatViewController.swift
//  Discover
//
//  Created by Sowndharya on 19/11/16.
//  Copyright © 2016 Sowndharya. All rights reserved.
//

import UIKit
import Foundation
import MediaPlayer
import Parse
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var timer: Timer = Timer()
    var isLoading: Bool = false
    
    var groupId: String = ""
    
    var users = [PFUser]()
    var messages = [JSQMessage]()
    var avatars = Dictionary<String, JSQMessagesAvatarImage>()
    
    var bubbleFactory = JSQMessagesBubbleImageFactory()
    var outgoingBubbleImage: JSQMessagesBubbleImage!
    var incomingBubbleImage: JSQMessagesBubbleImage!
    
    var blankAvatarImage: JSQMessagesAvatarImage!
    
    var senderImageUrl: String!
    var batchMessages = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = PFUser.current() {
            self.senderId = user.objectId
            self.senderDisplayName = user[PF_USER_FULLNAME] as! String
        }
        
        outgoingBubbleImage = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        incomingBubbleImage = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        
        blankAvatarImage = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "profile_blank"), diameter: 30)
        
        isLoading = false
        self.loadMessages()
        Messages.clearMessageCounter(groupId);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView.collectionViewLayout.springinessEnabled = true
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(ChatViewController.loadMessages), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    
    // Mark: - Backend methods
    
    func loadMessages() {
        if self.isLoading == false {
            self.isLoading = true
            let lastMessage = messages.last
            
            let query = PFQuery(className: PF_CHAT_CLASS_NAME)
            query.whereKey(PF_CHAT_GROUPID, equalTo: groupId)
            if let lastMessage = lastMessage {
                query.whereKey(PF_CHAT_CREATEDAT, greaterThan: lastMessage.date)
            }
            query.includeKey(PF_CHAT_USER)
            query.order(byDescending: PF_CHAT_CREATEDAT)
            query.limit = 50
            query.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) -> Void in
                if error == nil {
                    self.automaticallyScrollsToMostRecentMessage = false
                    for object in (objects as [PFObject]!).reversed() {
                        self.addMessage(object)
                    }
                    if objects!.count > 0 {
                        self.finishReceivingMessage()
                        self.scrollToBottom(animated: false)
                    }
                    self.automaticallyScrollsToMostRecentMessage = true
                } else {
                    let alertController = UIAlertController(title: "Error", message: "\(error)", preferredStyle: UIAlertControllerStyle.alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                        print("OK")
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                self.isLoading = false;
            })
        }
    }
    
    func addMessage(_ object: PFObject) {
        var message: JSQMessage!
        
        let user = object[PF_CHAT_USER] as! PFUser
        let name = user[PF_USER_FULLNAME] as! String
        
        let videoFile = object[PF_CHAT_VIDEO] as? PFFile
        let pictureFile = object[PF_CHAT_PICTURE] as? PFFile
        
        if videoFile == nil && pictureFile == nil {
            message = JSQMessage(senderId: user.objectId, senderDisplayName: name, date: object.createdAt, text: (object[PF_CHAT_TEXT] as? String))
        }
        
        if let videoFile = videoFile {
            let mediaItem = JSQVideoMediaItem(fileURL: URL(string: videoFile.url!), isReadyToPlay: true)
            mediaItem?.appliesMediaViewMaskAsOutgoing = (user.objectId == self.senderId)
            message = JSQMessage(senderId: user.objectId, senderDisplayName: name, date: object.createdAt, media: mediaItem)
        }
        
        if let pictureFile = pictureFile {
            let mediaItem = JSQPhotoMediaItem(image: nil)
            mediaItem?.appliesMediaViewMaskAsOutgoing = (user.objectId == self.senderId)
            message = JSQMessage(senderId: user.objectId, senderDisplayName: name, date: object.createdAt, media: mediaItem)
            
            pictureFile.getDataInBackground(block: { (imageData: Data?, error: Error?) -> Void in
                if error == nil {
                    mediaItem?.image = UIImage(data: imageData!)
                    self.collectionView.reloadData()
                }
            })
        }
        
        users.append(user)
        messages.append(message)
    }
    
    func sendMessage(_ text: String, video: URL?, picture: UIImage?) {
        var text = text
        var videoFile: PFFile!
        var pictureFile: PFFile!
        
        if let video = video {
            text = "[Video message]"
            videoFile = PFFile(name: "video.mp4", data: FileManager.default.contents(atPath: video.path)!)
            
            videoFile.saveInBackground(block: { (succeeed: Bool, error: Error?) -> Void in
                if error != nil {
                    let alertController = UIAlertController(title: "Error", message: "\(error)", preferredStyle: UIAlertControllerStyle.alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                        print("OK")
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }
        
        if let picture = picture {
            text = "[Picture message]"
            pictureFile = PFFile(name: "picture.jpg", data: UIImageJPEGRepresentation(picture, 0.6)!)
            pictureFile.saveInBackground(block: { (suceeded: Bool, error: Error?) -> Void in
                if error != nil {
                    let alertController = UIAlertController(title: "Picture Save Error", message: "\(error)", preferredStyle: UIAlertControllerStyle.alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                        print("OK")
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }
        
        let object = PFObject(className: PF_CHAT_CLASS_NAME)
        object[PF_CHAT_USER] = PFUser.current()
        object[PF_CHAT_GROUPID] = self.groupId
        object[PF_CHAT_TEXT] = text
        if let videoFile = videoFile {
            object[PF_CHAT_VIDEO] = videoFile
        }
        if let pictureFile = pictureFile {
            object[PF_CHAT_PICTURE] = pictureFile
        }
        object.saveInBackground{ (succeeded: Bool, error: Error?) -> Void in
            if error == nil {
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.loadMessages()
            } else {
                let alertController = UIAlertController(title: "Network Error", message: "\(error)", preferredStyle: UIAlertControllerStyle.alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                    print("OK")
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        PushNotication.sendPushNotification(groupId, text: text)
        Messages.updateMessageCounter(groupId, lastMessage: text)
        
        self.finishSendingMessage()
    }
    
    // MARK: - JSQMessagesViewController method overrides
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        self.sendMessage(text, video: nil, picture: nil)
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        self.view.endEditing(true)
        
        let action = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Take photo", "Choose existing photo", "Choose existing video")
        action.show(in: self.view)
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return self.messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {
        
        let message = self.messages[indexPath.item]
        if message.senderId == self.senderId {
            return outgoingBubbleImage
        }
        return incomingBubbleImage
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        let user = self.users[indexPath.item]
        if self.avatars[user.objectId!] == nil {
            let thumbnailFile = user[PF_USER_THUMBNAIL] as? PFFile
            
            thumbnailFile?.getDataInBackground(block: { (imageData: Data?, error: Error?) -> Void in
                if error == nil {
                    self.avatars[user.objectId!] = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(data: imageData!), diameter: 30)
                    self.collectionView.reloadData()
                }
            })
            
            return blankAvatarImage
        } else {
            return self.avatars[user.objectId!]
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        
        if indexPath.item % 3 == 0 {
            let message = self.messages[indexPath.item]
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        return nil;
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        let message = self.messages[indexPath.item]
        if message.senderId == self.senderId {
            return nil
        }
        
        if indexPath.item > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == message.senderId {
                return nil
            }
        }
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    
    //    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: IndexPath!) -> NSAttributedString! {
    //        return nil
    //    }
    
    // MARK: - UICollectionView DataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    //    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    //        var cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
    //
    //        var message = self.messages[indexPath.item]
    //        if message.senderId == self.senderId {
    //            cell.textView?.textColor = UIColor.whiteColor()
    //        } else {
    //            cell.textView?.textColor = UIColor.blackColor()
    //        }
    //        return cell
    //    }
    
    // MARK: - UICollectionView flow layout
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAt indexPath: IndexPath) -> CGFloat {
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat {
        
        let message = self.messages[indexPath.item]
        if message.senderId == self.senderId {
            return 0
        }
        
        if indexPath.item > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == message.senderId {
                return 0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    //    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: IndexPath!) -> CGFloat {
    //        return 0
    //    }
    
    // MARK: - Responding to CollectionView tap events
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        print("didTapLoadEarlierMessagesButton")
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, at indexPath: IndexPath!) {
        print("didTapAvatarImageview")
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let message = self.messages[indexPath.item]
        if message.isMediaMessage {
            if let mediaItem = message.media as? JSQVideoMediaItem {
                let moviePlayer = MPMoviePlayerViewController(contentURL: mediaItem.fileURL)
                self.presentMoviePlayerViewControllerAnimated(moviePlayer)
                moviePlayer?.moviePlayer.play()
            }
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapCellAt indexPath: IndexPath!, touchLocation: CGPoint) {
        print("didTapCellAtIndexPath")
    }
    
    // MARK: - UIActionSheetDelegate
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            //            if buttonIndex == 1 {
            //                Camera.shouldStartCamera(self, canEdit: true, frontFacing: true)
            //            } else if buttonIndex == 2 {
            //                Camera.shouldStartPhotoLibrary(self, canEdit: true)
            //            } else if buttonIndex == 3 {
            //                Camera.shouldStartVideoLibrary(self, canEdit: true)
            //            }
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [AnyHashable: Any]) {
        let video = info[UIImagePickerControllerMediaURL] as? URL
        let picture = info[UIImagePickerControllerEditedImage] as? UIImage
        
        self.sendMessage("", video: video, picture: picture)
        
        picker.dismiss(animated: true, completion: nil)
    }
}

