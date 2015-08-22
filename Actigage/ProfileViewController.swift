//
//  ProfileViewController.swift
//  TestProject
//
//  Created by Anya on 03/08/2015.
//  Copyright (c) 2015 Anya. All rights reserved.
//

import Foundation

class ProfileViewController : UIViewController, UITextFieldDelegate {
    @IBOutlet var nameLabel : UILabel?
    @IBOutlet var nameField : UITextField?
    @IBOutlet var button : UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField?.delegate = self
    }
        
    @IBAction func fieldChanged() {
        if ((nameField?.text?.isEmpty) == nil || !nameField!.text!.isEmpty) {
            button?.enabled = true
        } else {
            button?.enabled = false
        }
    }
    
    @IBAction func buttonPressed(sender: UIButton) {
//        let viewDeck : IIViewDeckController? = self.parentViewController as? IIViewDeckController
//        viewDeck?.closeRightViewAnimated(true)
        
        let editing = nameLabel?.hidden
        
        if (editing != nil && editing!) {
            nameLabel?.text = nameField?.text
            nameLabel?.hidden = false
            nameField?.resignFirstResponder()
            nameField?.hidden = true
            button?.setTitle("Edit", forState: UIControlState.Normal)
        } else {
            nameField?.text = nameLabel?.text
            nameField?.hidden = false
            nameLabel?.hidden = true
            button?.setTitle("Done", forState: UIControlState.Normal)
        }
    }
}