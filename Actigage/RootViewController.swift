//
//  ViewController.swift
//  TestProject
//
//  Created by Anya on 20/04/2015.
//  Copyright (c) 2015 Anya. All rights reserved.
//

import UIKit

class RootViewController: UITabBarController {
    private var newMessageUUIDs = Set<String>()

    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("peripheralMessage:"), name: CommunicationNotification.PeripheralReceivedMessage, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("badgeCleared:"), name: ChatHistoryNotification.BadgeCleared, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func peripheralMessage(notification : NSNotification){
        if let dictionary = notification.userInfo as? Dictionary<String,String> {
            let uuid = dictionary["uuid"]
            if (uuid != nil && ActiveChatDataManager.sharedInstance.chatData?.user.uuid != uuid) {
                newMessageUUIDs.insert(uuid!)
            }
        }
        if (newMessageUUIDs.count > 0){
            self.tabBar.items?[1].badgeValue = "\(newMessageUUIDs.count)"            
        }
    }
    
    func badgeCleared(notification : NSNotification){
        newMessageUUIDs.removeAll()
    }
}

