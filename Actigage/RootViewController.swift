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
        
        var nearbyItem = tabBar.items?[0]
        var historyItem = tabBar.items?[1]
        
        nearbyItem!.image = UIImage(named: "nearby.png")?.imageWithRenderingMode(.AlwaysOriginal)
        nearbyItem!.selectedImage = UIImage(named: "nearby_selected.png")?.imageWithRenderingMode(.AlwaysOriginal)
        historyItem!.image = UIImage(named: "history.png")?.imageWithRenderingMode(.AlwaysOriginal)
        historyItem!.selectedImage = UIImage(named: "history_selected.png")?.imageWithRenderingMode(.AlwaysOriginal)
        
        nearbyItem?.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor( red: 0.0, green: 0.388, blue: 0.388, alpha: 1.0)], forState: .Normal)
        historyItem?.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor( red: 0.0, green: 0.388, blue: 0.388, alpha: 1.0)], forState: .Normal)

        nearbyItem?.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor( red: 1.0, green: 0.588, blue: 0.251, alpha: 1.0)], forState: .Highlighted)
        historyItem?.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor( red: 1.0, green: 0.588, blue: 0.251, alpha: 1.0)], forState: .Highlighted)
        
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
}

