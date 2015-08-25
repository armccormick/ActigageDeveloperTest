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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        senderId = CommunicationManager.UUIDString  // TODO:  Not the right string here?
        senderDisplayName = CommunicationManager.sharedInstance.displayName
        self.collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        self.collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        let imageFactory : JSQMessagesBubbleImageFactory = JSQMessagesBubbleImageFactory()
        incomingImageData = imageFactory.incomingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
        outgoingImageData = imageFactory.outgoingMessagesBubbleImageWithColor(UIColor(colorLiteralRed: 0.0, green: 0.388, blue: 0.388, alpha: 1.0))
        
        self.inputToolbar!.contentView!.leftBarButtonItem = nil
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = ActiveChatDataManager.sharedInstance.chatData?.user.displayName
        self.collectionView?.reloadData()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("receivedMessage:"), name: CommunicationNotification.CentralReceivedMessage, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("receivedMessage:"), name: CommunicationNotification.PeripheralReceivedMessage, object: nil)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        CommunicationManager.sharedInstance.disconnect()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.scrollToBottomAnimated(true)
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return ActiveChatDataManager.sharedInstance.chatData!.messages[indexPath.row]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        ActiveChatDataManager.sharedInstance.deleteMessageAtIndex(indexPath.row)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message : JSQMessageData = ActiveChatDataManager.sharedInstance.chatData!.messages[indexPath.row]
        
        if (message.senderId() == senderId) {
            return outgoingImageData
        }
        
        return incomingImageData
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ActiveChatDataManager.sharedInstance.chatData!.messages.count
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        CommunicationManager.sharedInstance.sendMessage((ActiveChatDataManager.sharedInstance.chatData?.user.uuid)!, date: date, text: text)
        self.finishSendingMessageAnimated(true)
    }
    
    func receivedMessage(notification : NSNotification){
        self.finishReceivingMessageAnimated(true)
    }
}