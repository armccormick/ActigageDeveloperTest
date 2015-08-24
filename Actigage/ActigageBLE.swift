//
//  ActigageBLE.swift
//  Actigage
//
//  Created by Anya on 22/08/2015.
//  Copyright © 2015 Anya. All rights reserved.
//

import Foundation

// Adds some useful methods to BLE class and its delegate
class ActigageBLE : BLE {
    var actigageDelegate : ActigageBLEDelegate? {
        didSet {
            self.delegate = actigageDelegate
        }
    }
    
    override func centralManagerDidUpdateState(central: CBCentralManager) {
        actigageDelegate?.centralManagerDidUpdateState(central)
    }
    
    override func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        NSLog("failed to connect to %@:", peripheral)
        if (error != nil){
            NSLog("%@", error!)
        } else {
            NSLog("Unknown Error")
        }
        actigageDelegate?.centralManagerFailedToConnect()
    }
    
    func disconnect() {
        if (activePeripheral != nil && activePeripheral.state == CBPeripheralState.Connected){
            CM.cancelPeripheralConnection(activePeripheral)
        }
    }
}

protocol ActigageBLEDelegate : BLEDelegate  {
    func centralManagerDidUpdateState(central : CBCentralManager)
    func centralManagerFailedToConnect()
}