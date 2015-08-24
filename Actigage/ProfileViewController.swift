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
        nameField?.text = CommunicationManager.sharedInstance.displayName
        nameLabel?.text = CommunicationManager.sharedInstance.displayName
    }
        
    @IBAction func fieldChanged() {
        if ((nameField?.text?.isEmpty) == nil || !nameField!.text!.isEmpty) {
            button?.enabled = true
        } else {
            button?.enabled = false
        }
    }
    
    @IBAction func buttonPressed(sender: UIButton) {
        
        let editing = nameLabel?.hidden
        
        if (editing != nil && editing!) {
            let name = nameField?.text
            nameLabel?.text = nameField?.text
            nameLabel?.hidden = false
            nameField?.resignFirstResponder()
            nameField?.hidden = true
            button?.setTitle("Edit", forState: UIControlState.Normal)
            ActigageFileManager.sharedInstance.saveData(name, key: ActigageDataKey.UserDisplayName)
            print(ActigageFileManager.sharedInstance.retrieveData(ActigageDataKey.UserDisplayName))
        } else {
            nameField?.text = nameLabel?.text
            nameField?.hidden = false
            nameLabel?.hidden = true
            button?.setTitle("Done", forState: UIControlState.Normal)
        }
    }
}