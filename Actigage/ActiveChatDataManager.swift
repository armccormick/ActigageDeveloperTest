//
//  CurrentChatDataManager.swift
//  Actigage
//
//  Created by Anya on 24/08/2015.
//  Copyright © 2015 Anya. All rights reserved.
//

import Foundation

class ActiveChatDataManager {
    static var sharedInstance = ActiveChatDataManager()
    
    var chatData : UserChatHistory?
    var isCentral = false
    
    func retrieveChatData(uuid : String) {
        chatData = CommunicationManager.sharedInstance.chatDataForUUID(uuid)
    }
    
    func deleteMessageAtIndex(index : Int) {
        if (chatData != nil){
            chatData!.messages.removeAtIndex(index)
            CommunicationManager.sharedInstance.saveAllMessages()
        } else {
            // Unlikely, but let's log it for the developer in case it happens
            NSLog("Something went terribly wrong!  Deleting message when chatdata is nil!!")
        }
    }
}