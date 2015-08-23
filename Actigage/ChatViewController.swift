//
//  ChatViewController.swift
//  Actigage
//
//  Created by Anya on 22/08/2015.
//  Copyright © 2015 Anya. All rights reserved.
//

import Foundation

class ChatViewController : JSQMessagesViewController {
    
    private var outgoingImageData : JSQMessageBubbleImageDataSource?
    private var incomingImageData : JSQMessageBubbleImageDataSource?
    
    var messages = [JSQMessageData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        senderId = CommunicationManager.UUIDString
        senderDisplayName = CommunicationManager.sharedInstance.displayName
        self.collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        self.collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        let imageFactory : JSQMessagesBubbleImageFactory = JSQMessagesBubbleImageFactory()
        incomingImageData = imageFactory.incomingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
        outgoingImageData = imageFactory.outgoingMessagesBubbleImageWithColor(UIColor.greenColor())

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("receivedCentralMessage:"), name: CommunicationNotification.CentralReceivedMessage, object: nil)
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        print(messages)
        return messages[indexPath.row]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        messages.removeAtIndex(indexPath.row)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message : JSQMessageData = messages[indexPath.row]
        
        if (message.senderId() == senderId) {
            return outgoingImageData
        }
        
        return incomingImageData
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        print("message send")
        
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        messages.append(message)
        print(message)
        print(messages)
        
        CommunicationManager.sharedInstance.sendMessage(text)
        
        self.finishSendingMessageAnimated(true)
    }
    
    func receivedCentralMessage(notification : NSNotification){
        print("received message")
        if let dictionary = notification.userInfo as? Dictionary<String,JSQMessage> {
            if let message = dictionary["message"] {
                print(message)
                messages.append(message)
                self.finishReceivingMessageAnimated(true)
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        CommunicationManager.sharedInstance.disconnect()
    }
}