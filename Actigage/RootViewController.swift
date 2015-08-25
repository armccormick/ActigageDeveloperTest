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
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if (item == self.tabBar.items?[1]){
            newMessageUUIDs.removeAll()
            self.tabBar.items?[1].badgeValue = nil
        }
    }
    
    
    func peripheralMessage(notification : NSNotification){
        if let dictionary = notification.userInfo as? Dictionary<String,String> {
            let uuid = dictionary["uuid"]
            if (uuid != nil && ActiveChatDataManager.sharedInstance.chatData?.user.uuid != uuid && tabBar.selectedItem != tabBar.items?[1]) {
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

