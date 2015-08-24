//
//  SecondViewController.swift
//  Actigage
//
//  Created by Anya on 20/08/2015.
//  Copyright (c) 2015 Anya. All rights reserved.
//

import UIKit

struct ChatHistoryNotification {
    static let BadgeCleared = "kBadgeCleared"
}

class ChatHistoryViewController: UITableViewController {
    var chatHistoryList : [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatHistoryList = CommunicationManager.sharedInstance.chatHistoryUsers()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.parentViewController?.navigationItem.title = "Chat History"
        self.tabBarItem.badgeValue = nil
        let notification = NSNotification(name: ChatHistoryNotification.BadgeCleared, object: nil, userInfo: nil)
        NSNotificationCenter.defaultCenter().postNotification(notification)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("peripheralMessage:"), name: CommunicationNotification.PeripheralReceivedMessage, object: nil)

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("creating cell")
        let cellIdentifier = "HistoryCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        
        if (cell == nil) {
            cell = HistoryCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        
        let c : HistoryCell = cell as! HistoryCell
        
        c.nameLabel?.text = chatHistoryList[indexPath.row].displayName
        return c
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController?
        ActiveChatDataManager.sharedInstance.retrieveChatData(chatHistoryList[indexPath.row].uuid)
        
        if (CommunicationManager.sharedInstance.isConnectedToUser(chatHistoryList[indexPath.row])){
            ActiveChatDataManager.sharedInstance.isCentral = false
        } else {
            CommunicationManager.sharedInstance.connectToUser(chatHistoryList[indexPath.row])
        }
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CommunicationManager.sharedInstance.chatHistoryUsers().count
    }

    func peripheralMessage(notification : NSNotification){
        self.tableView.reloadData()
    }
    
    @IBAction func buttonPressed(sender: UIButton) {
        let viewDeck : IIViewDeckController? = self.navigationController?.parentViewController?.parentViewController as? IIViewDeckController
        viewDeck?.openRightViewAnimated(true)
        
    }

}

