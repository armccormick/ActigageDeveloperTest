//
//  SecondViewController.swift
//  Actigage
//
//  Created by Anya on 20/08/2015.
//  Copyright (c) 2015 Anya. All rights reserved.
//

import UIKit

class ChatHistoryViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.parentViewController?.navigationItem.title = "Chat"
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

