//
//  ViewDeckController.swift
//  TestProject
//
//  Created by Anya on 03/08/2015.
//  Copyright (c) 2015 Anya. All rights reserved.
//

import Foundation

class ViewDeckController : IIViewDeckController, IIViewDeckControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.centerController = self.storyboard?.instantiateViewControllerWithIdentifier("RootViewController") as UIViewController?
        self.leftController = nil
        self.rightController = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileViewController") as UIViewController?
        self.delegate = self
    }
    
    func viewDeckController(viewDeckController: IIViewDeckController!, shouldOpenViewSide viewDeckSide: IIViewDeckSide) -> Bool {
        return Int(viewDeckSide) == IIViewDeckLeftSide ? false : true
    }
    
}