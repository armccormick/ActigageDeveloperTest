//
//  ActigageBLE.swift
//  Actigage
//
//  Created by Anya on 22/08/2015.
//  Copyright © 2015 Anya. All rights reserved.
//

import Foundation

class ActigageBLE : BLE {
    var actigageDelegate : ActigageBLEDelegate? {
        didSet {
            self.delegate = actigageDelegate
        }
    }
    
    override func centralManagerDidUpdateState(central: CBCentralManager) {
        actigageDelegate?.centralManagerDidUpdateState(central)
    }
}

protocol ActigageBLEDelegate : BLEDelegate  {
    func centralManagerDidUpdateState(central : CBCentralManager)
}