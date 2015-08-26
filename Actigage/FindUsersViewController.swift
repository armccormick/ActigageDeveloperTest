//
//  FirstViewController.swift
//  Actigage
//
//  Created by Anya on 20/08/2015.
//  Copyright (c) 2015 Anya. All rights reserved.
//

import UIKit
import CoreBluetooth

class FindUsersViewController: UITableViewController {
    var nearbyList : [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateNearby:"), name: CommunicationNotification.NearbyListUpdated, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.parentViewController?.navigationItem.title = "Nearby"
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateNearby(notification : NSNotification){
        nearbyList = CommunicationManager.sharedInstance.nearbyUsers()
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "NearbyCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        
        if (cell == nil) {
            cell = NearbyCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        
        let c : NearbyCell = cell as! NearbyCell
        
        let user : User = nearbyList[indexPath.row]
        
        c.nameLabel?.text = user.displayName
        
        return c
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController?
        ActiveChatDataManager.sharedInstance.retrieveChatData(nearbyList[indexPath.row].uuid)
        
        // If we're already connected, then we're in a peripheral role
        if (CommunicationManager.sharedInstance.isConnectedToUser(nearbyList[indexPath.row])){
            ActiveChatDataManager.sharedInstance.isCentral = false
            
            // If we're not already connected, we can connect as central
        } else {
            CommunicationManager.sharedInstance.connectToUser(nearbyList[indexPath.row])
        }
        
        // TODO: We should show the user some feedback if they cannot connect
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyList.count
    }

    @IBAction func buttonPressed(sender: UIButton) {
        let viewDeck : IIViewDeckController? = self.navigationController?.parentViewController?.parentViewController as? IIViewDeckController
        viewDeck?.openRightViewAnimated(true)
        
    }

}

