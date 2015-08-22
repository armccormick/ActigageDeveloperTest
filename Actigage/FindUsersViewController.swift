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
    var nearbyList : [CBPeripheral] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateNearby"), name: CommunicationNotification.NearbyListUpdated, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.parentViewController?.navigationItem.title = "Nearby"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateNearby(){
        print("NOTIFICATION RECEIVED!!!")
        nearbyList = CommunicationManager.sharedInstance.nearbyList
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
        
        let user : CBPeripheral = nearbyList[indexPath.row]
        
        c.nameLabel?.text = user.name
        
        return c
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        CommunicationManager.sharedInstance.connectToUser(nearbyList[indexPath.row])
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyList.count
    }

}

