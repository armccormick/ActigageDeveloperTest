//
//  ViewController.swift
//  TestProject
//
//  Created by Anya on 20/04/2015.
//  Copyright (c) 2015 Anya. All rights reserved.
//

import UIKit

class RootViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        let not = UILocalNotification()
//        not.alertBody = "Hello"
//        not.alertTitle = "Title"
//        not.fireDate = NSDate().dateByAddingTimeInterval(10)
//        UIApplication.sharedApplication().scheduleLocalNotification(not)
//    }
    
    @IBAction func buttonPressed(sender: UIButton) {
        let viewDeck : IIViewDeckController? = self.parentViewController?.parentViewController as? IIViewDeckController
        viewDeck?.openRightViewAnimated(true)
        
    }


}

