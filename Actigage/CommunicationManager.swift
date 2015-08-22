//
//  CommunicationManager.swift
//  Actigage
//
//  Created by Anya on 21/08/2015.
//  Copyright © 2015 Anya. All rights reserved.
//

import Foundation
//import CoreLocation
import CoreBluetooth

struct CommunicationNotification {
    static let NearbyListUpdated = "kNearbyListUpdated"
}

class CommunicationManager : NSObject, /*CLLocationManagerDelegate, */CBPeripheralManagerDelegate, ActigageBLEDelegate {
    static let sharedInstance = CommunicationManager()
    
//    let locationManager = CLLocationManager()
//    let uuid = NSUUID(UUIDString: "A8AA6B07-1485-4A0A-9FEC-468C8EF19ABC")
    private let ble = ActigageBLE()
    private var peripheralManager : CBPeripheralManager?
//    var region : CLBeaconRegion?
    
    var nearbyList : [CBPeripheral] = []
    
    
    override init() {
        super.init()
        initializeBLECentralRole()
        initializeLocalNotifications()
        initializeBLEPeripheralRole()
        
        
        // iBeacons
//        locationManager.delegate = self

        
//        if (uuid == nil) { print("uuid is nil") }
//        region = CLBeaconRegion(proximityUUID: uuid!, major: 42, minor: 666, identifier: "Actigage")

//        if #available(iOS 8.0, *) {
        
//            if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse) {
//                locationManager.requestWhenInUseAuthorization()
//                print("Requested for locations - iOS 8+")
//            }
            
//        } else {
        
//            locationManager.startUpdatingLocation()
//            print("Requested for locations - iOS 7")
            
//        }
        
//        locationManager.startRangingBeaconsInRegion(region!)

    }
    
    private func initializeLocalNotifications(){
        if #available(iOS 8.0, *) {
            let types : UIUserNotificationType = [UIUserNotificationType.Badge, UIUserNotificationType.Sound, UIUserNotificationType.Alert]
            let mySettings : UIUserNotificationSettings = UIUserNotificationSettings.init(forTypes: types, categories:nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(mySettings)
            print("Requested for notifications - iOS 8+")
        } else {
            UIApplication.sharedApplication().registerForRemoteNotificationTypes([UIRemoteNotificationType.Alert, UIRemoteNotificationType.Badge, UIRemoteNotificationType.Sound])
            print("Requested for notifications - iOS 7")
        }
    }
    
    private func initializeBLECentralRole(){
        ble.controlSetup()
        ble.actigageDelegate = self
    }
    
    private func initializeBLEPeripheralRole() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
    }
    
    internal func centralManagerDidUpdateState(central: CBCentralManager) {
        print(ble.CM.state)
        ble.findBLEPeripherals(3)
        NSTimer.scheduledTimerWithTimeInterval(Double(3.0), target:self, selector: Selector("connectionTimer:"), userInfo:nil, repeats: false)
    }
    
    internal func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        print("changed state")
        // We must construct a CLBeaconRegion that represents the payload we want the device to beacon.
        print("Setting up beacon")
        
//        let peripheralData : NSDictionary = region!.peripheralDataWithMeasuredPower(nil)
        
//        if (peripheralManager == nil) { print("peripheralManager is nil") }
//        print(peripheralData)
        
        // The region's peripheral data contains the CoreBluetooth-specific data we need to advertise.
//        print("Starting beacon")
//        if (peripheralManager!.state == CBPeripheralManagerState.PoweredOn){
// //            peripheralManager!.startAdvertising((peripheralData as! [String : AnyObject]))
//            let writable = CBMutableCharacteristic(type: CBUUID(NSUUID: uuid!), properties: CBCharacteristicProperties.WriteWithoutResponse, value: nil, permissions: CBAttributePermissions.Writeable)
//            let readable = CBMutableCharacteristic(type: CBUUID(NSUUID: uuid!), properties: CBCharacteristicProperties.Notify, value: nil, permissions: CBAttributePermissions.Readable)
//            let service = CBMutableService(type: CBUUID(NSUUID: uuid!), primary: true)
//            service.characteristics = [writable, readable]
//            
//            print(service)
//
//            peripheralManager!.addService(service)
//            let data = [CBAdvertisementDataLocalNameKey : "iOS Chatter", CBAdvertisementDataServiceUUIDsKey : [CBUUID(NSUUID: uuid!)]]
//            peripheralManager!.startAdvertising(data)
//            print(data)
//
//            print("Started beacon")
//
//        } else {
//            print(peripheralManager!.state.rawValue)
//            print("Did not start beacon")
//        }
    }

//    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
//        for beacon : CLBeacon in beacons {
//            print(beacon)
//        }
//    }
    
    internal func connectionTimer(timer:NSTimer){
        nearbyList = ble.peripherals! as NSArray as! [CBPeripheral]
        let notification = NSNotification(name: CommunicationNotification.NearbyListUpdated, object: nil, userInfo: nil)
        NSNotificationCenter.defaultCenter().postNotification(notification)
        
    }
    
    func connectToUser(user:CBPeripheral) {
        ble.connectPeripheral(user)
    }
    
    func bleDidConnect() {
        print("Connected!")
    }
    
    func bleDidDisconnect() {
        print("Disconnected")
    }
}

