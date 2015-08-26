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
    static let CentralReceivedMessage = "kCentralReceivedMessage"
    static let CentralFailedToConnect = "kFailedToConnect"
    static let PeripheralReceivedMessage = "kPeripheralReceivedMessage"
}

class CommunicationManager : NSObject, CBPeripheralManagerDelegate, ActigageBLEDelegate {
    static let sharedInstance = CommunicationManager()
    static let UUIDString = "713D0000-503E-4C75-BA94-3148F18D941E"//"A8AA6B07-1485-4A0A-9FEC-468C8EF19ABC"
    
    private let SERIVCE_UUID = "713D0000-503E-4C75-BA94-3148F18D941E"
    private let READ_CHARACTERISTIC_UUID = "713D0002-503E-4C75-BA94-3148F18D941E"
    private let WRITE_CHARACTERISTIC_UUID = "713D0003-503E-4C75-BA94-3148F18D941E"
    
    private let ble = ActigageBLE()
    private var peripheralManager : CBPeripheralManager?
    private var subscribedCentrals : [CBCentral] = []
    private var readCharacteristic : CBMutableCharacteristic?
    
    private var allMessages : [String : UserChatHistory] = [:]

    var displayName : String = UIDevice.currentDevice().name // Default to device name
    private var nearbyList : [CBPeripheral] = []

    override init() {
        super.init()
        
        let storedName = ActigageFileManager.sharedInstance.retrieveData(.UserDisplayName) as? String
        if (storedName != nil) {
            displayName = storedName!
        }
        
        let storedMessages = ActigageFileManager.sharedInstance.retrieveData(.MessageHistory) as? [String : UserChatHistory]
        if (storedMessages != nil){
            allMessages = storedMessages!
        }
        
        initializeBLECentralRole()
//        initializeLocalNotifications()
        initializeBLEPeripheralRole()
    }
    
    // Initialization
    
    // Local Notifications are currently unused, but would be a nice addition.
//    private func initializeLocalNotifications(){
//        if #available(iOS 8.0, *) {
//            let types : UIUserNotificationType = [UIUserNotificationType.Badge, UIUserNotificationType.Sound, UIUserNotificationType.Alert]
//            let mySettings : UIUserNotificationSettings = UIUserNotificationSettings.init(forTypes: types, categories:nil)
//            UIApplication.sharedApplication().registerUserNotificationSettings(mySettings)
//            print("Requested for notifications - iOS 8+")
//        } else {
//            UIApplication.sharedApplication().registerForRemoteNotificationTypes([UIRemoteNotificationType.Alert, UIRemoteNotificationType.Badge, UIRemoteNotificationType.Sound])
//            print("Requested for notifications - iOS 7")
//        }
//    }
    
    // Set up BLE central role
    private func initializeBLECentralRole(){
        ble.controlSetup()
        ble.actigageDelegate = self
    }
    
    // Set up BLE peripheral role
    private func initializeBLEPeripheralRole() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
    }
    
    
    // Utilities
    
    // Convenience method for active peripheral's uuid
    func activePeripheralUUID() -> String? {
        return ble.activePeripheral?.identifier.UUIDString
    }

    // List of users for chat history list
    func chatHistoryUsers() -> [User] {
        var array : [User] = []
        for key in allMessages.keys {
            if (allMessages[key] != nil && allMessages[key]!.messages.count > 0){
                array.append(allMessages[key]!.user)
            }
        }
        
        return array
    }
    
    // List of nearby users for nearby list
    func nearbyUsers() -> [User] {
        var users : [User] = []
        for p in ble.peripherals {
            let u = User(uuid: p.identifier.UUIDString, displayName: p.name)
            users.append(u)
        }
        return users
    }
    
    // Convenience method for chat history from a particular device
    func chatDataForUUID(uuid : String) -> UserChatHistory {
        var data = allMessages[uuid]
        if (data == nil){
            data = UserChatHistory(uuid: uuid, displayName: self.findDisplayNameForUUID(uuid))
            allMessages[uuid] = data
        }
        
        return data!
    }
    
    // Try to figure out the name of a central
    // This is ugly, but centrals don't tell us their names...
    func findDisplayNameForUUID(uuid : String) -> String {
        var name : String?
        
        if (ble.peripherals != nil){
            // look for the current broadcast of the central's uuid as a peripheral
            for c in ble.peripherals as NSArray {
                if (c.identifier.UUIDString == uuid) {
                    name = c.name
                }
            }
        }
        
        // if we didn't find it, look in chat history
        if (name == nil){
            if let history = allMessages[uuid] {
                name = history.user.displayName!
            }
        }
        
        // If we still didn't find it, mark it as unknown
        if (name == nil) {
            name = "Unknown User"
        }
        return name!
    }
    
    // Sync all messages to disk.  This will be too much IO work after a while.  
    // Should rewrite to save only the messages that changed.
    func saveAllMessages() {
        ActigageFileManager.sharedInstance.saveData(allMessages, key: .MessageHistory)
    }
    
    // Find the central with the given uuid
    func findCentral(uuid : String) -> CBCentral? {
        for c in subscribedCentrals {
            if (c.identifier.UUIDString == uuid){
                return c
            }
        }
        return nil
    }
    
    // Determine whether we're already connected to a user
    func isConnectedToUser(user : User) -> Bool {
        if (findCentral(user.uuid) != nil || activePeripheralUUID() == user.uuid){
            return true
        }
        return false
    }
    
    // Central Role Delegate Methods
    
    internal func centralManagerDidUpdateState(central: CBCentralManager) {
        ble.findBLEPeripherals(3)
        NSTimer.scheduledTimerWithTimeInterval(Double(3.0), target:self, selector: Selector("connectionTimer:"), userInfo:nil, repeats: true)
    }
    
    internal func centralManagerFailedToConnect() {
        let not = NSNotification(name: CommunicationNotification.CentralFailedToConnect, object: nil, userInfo: nil)
        NSNotificationCenter.defaultCenter().postNotification(not)
    }
    
    func bleDidConnect() {
        NSLog("BLE Connected")
    }
    
    func bleDidDisconnect() {
        NSLog("BLE Disconnected")
        ble.activePeripheral = nil
    }

    func bleDidReceiveData(data: UnsafeMutablePointer<UInt8>, length: Int32) {
        NSLog("Received message from peripheral")
        let d = NSData(bytes: data, length: Int(length))
        let s = NSString(data: d, encoding: NSUTF8StringEncoding)

        let message : JSQMessage = JSQMessage(senderId: activePeripheralUUID(), senderDisplayName: ble.activePeripheral.name, date: NSDate(), text: s as? String)
        
        ActiveChatDataManager.sharedInstance.chatData?.messages.append(message)
        ActiveChatDataManager.sharedInstance.chatData?.user.displayName = message.senderDisplayName
        saveAllMessages()
        
        let not = NSNotification(name: CommunicationNotification.CentralReceivedMessage, object: nil, userInfo: ["message" : message])
        NSNotificationCenter.defaultCenter().postNotification(not)
    }
    

    // Central Role Connection Methods
    
    internal func connectionTimer(timer:NSTimer){
        if (ble.peripherals != nil) {
            nearbyList = ble.peripherals! as NSArray as! [CBPeripheral]
            let notification = NSNotification(name: CommunicationNotification.NearbyListUpdated, object: nil, userInfo: nil)
            NSNotificationCenter.defaultCenter().postNotification(notification)
        }
        ble.findBLEPeripherals(3)
    }
    
    func connectToUser(user:User) {
        var peripheral : CBPeripheral?
        if (ble.peripherals != nil) {
            for p in ble.peripherals {
                if (p.identifier.UUIDString == user.uuid){
                    peripheral = p as? CBPeripheral
                }
            }
            if (peripheral != nil){
                ble.connectPeripheral(peripheral)
            } else {
                // Tell user they can't connect
            }            
        }
    }
    
    func disconnect(){
        ble.disconnect()
    }
    
    // Send for both peripheral and central roles
    func sendMessage(toUUID: String, date: NSDate, text: String){
        NSLog("Sending message to %@", toUUID)
        let message = JSQMessage(senderId: CommunicationManager.UUIDString, senderDisplayName: displayName, date: date, text: text)
        let data = text.dataUsingEncoding(NSUTF8StringEncoding)
        ActiveChatDataManager.sharedInstance.chatData?.messages.append(message)
        saveAllMessages()
        
        if (activePeripheralUUID() == toUUID){
            
            if (ble.activePeripheral.state == CBPeripheralState.Connected){
                ble.write(data)
            }
        } else {
            let c = findCentral(toUUID)
            if (c != nil){
                peripheralManager?.updateValue(data!, forCharacteristic: readCharacteristic!, onSubscribedCentrals: [c!])
            }
        }
        
    }
    
    
    // Peripheral Role Delegate Methods
    
    internal func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        NSLog("Setting up advertising")
        
        if (peripheralManager!.state == CBPeripheralManagerState.PoweredOn){
            let write = CBMutableCharacteristic(     type: CBUUID(NSUUID: NSUUID(UUIDString: WRITE_CHARACTERISTIC_UUID)!),
                                               properties: CBCharacteristicProperties.WriteWithoutResponse,
                                                    value: nil,
                                              permissions: CBAttributePermissions.Writeable)
            
            let read = CBMutableCharacteristic(      type: CBUUID(NSUUID: NSUUID(UUIDString: READ_CHARACTERISTIC_UUID)!),
                                               properties: CBCharacteristicProperties.Notify,
                                                    value: nil,
                                              permissions: CBAttributePermissions.Readable)
            
            readCharacteristic = read
            
            let service = CBMutableService(type: CBUUID(NSUUID: NSUUID(UUIDString: SERIVCE_UUID)!), primary: true)
            service.characteristics = [write, read]
            
            peripheralManager!.addService(service)
            let data = [CBAdvertisementDataLocalNameKey : "iOS Chatter", CBAdvertisementDataServiceUUIDsKey : [CBUUID(NSUUID: NSUUID(UUIDString: SERIVCE_UUID)!)]]
            peripheralManager!.startAdvertising(data)

            NSLog("Started advertising")

        } else {
            NSLog("Did not start advertising")
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest]) {
        NSLog("Received message from central")
        let request : CBATTRequest = requests[0]
        let requestData : NSData = request.value!
        let sId = request.central.identifier.UUIDString
        let sName : String = self.findDisplayNameForUUID(sId)
        
        NSLog("Central UUID: %@", sId)

        var s = NSString(data: requestData, encoding: NSUTF8StringEncoding)
        if (s == nil) {
            s = ""
        }
        NSLog("Message is: %@", s!)
        
        let message = JSQMessage(senderId: sId, senderDisplayName: sName, date: NSDate(), text: s as! String)
        if (allMessages[sId] == nil){
            let chatHistory = UserChatHistory(uuid: sId, displayName: sName)
            allMessages[sId] = chatHistory
        }
        
        allMessages[sId]?.messages.append(message)
        allMessages[sId]?.user.displayName = sName
        saveAllMessages()
        
        let not = NSNotification(name: CommunicationNotification.PeripheralReceivedMessage, object: nil, userInfo: ["uuid" : sId])
        NSNotificationCenter.defaultCenter().postNotification(not)
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        if (characteristic.UUID == CBUUID(string: READ_CHARACTERISTIC_UUID)){
            subscribedCentrals.append(central)
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic) {
        let i = subscribedCentrals.indexOf(central)
        if (i != nil){
            subscribedCentrals.removeAtIndex(i!)
        }
    }
}

