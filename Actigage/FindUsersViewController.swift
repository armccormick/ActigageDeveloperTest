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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateNearby"), name: CommunicationNotification.NearbyListUpdated, object: nil)
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
    
    func updateNearby(){
        print("NOTIFICATION RECEIVED!!!")
        nearbyList = CommunicationManager.sharedInstance.nearbyUsers()
        tableView.reloadData()
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("creating cell")
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
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController?
        ActiveChatDataManager.sharedInstance.retrieveChatData(nearbyList[indexPath.row].uuid)
        ActiveChatDataManager.sharedInstance.isCentral = true
        CommunicationManager.sharedInstance.connectToUser(nearbyList[indexPath.row])
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

