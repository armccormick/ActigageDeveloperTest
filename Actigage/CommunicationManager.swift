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
}

class CommunicationManager : NSObject, /*CLLocationManagerDelegate, */CBPeripheralManagerDelegate, ActigageBLEDelegate {
    static let sharedInstance = CommunicationManager()
    static let UUIDString = "A8AA6B07-1485-4A0A-9FEC-468C8EF19ABC"
    
//    let locationManager = CLLocationManager()
    let uuid = NSUUID(UUIDString: "713D0000-503E-4C75-BA94-3148F18D941E")
    private let ble = ActigageBLE()
    private var peripheralManager : CBPeripheralManager?
//    var region : CLBeaconRegion?
    
    var nearbyList : [CBPeripheral] = []
    var displayName : String = UIDevice.currentDevice().name
    
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
    
    internal func centralManagerFailedToConnect() {
        // TODO:  Notification
        let not = NSNotification(name: CommunicationNotification.CentralFailedToConnect, object: nil, userInfo: nil)
        NSNotificationCenter.defaultCenter().postNotification(not)
    }
    
    internal func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        print("changed state")
        print("Setting up advertising")
        
//        let peripheralData : NSDictionary = region!.peripheralDataWithMeasuredPower(nil)
        
        if (peripheralManager == nil) { print("peripheralManager is nil") }
//        print(peripheralData)
        
//        print("Starting beacon")
        if (peripheralManager!.state == CBPeripheralManagerState.PoweredOn){
// //            peripheralManager!.startAdvertising((peripheralData as! [String : AnyObject]))
            let writable = CBMutableCharacteristic(type: CBUUID(NSUUID: uuid!), properties: CBCharacteristicProperties.WriteWithoutResponse, value: nil, permissions: CBAttributePermissions.Writeable)
            let readable = CBMutableCharacteristic(type: CBUUID(NSUUID: uuid!), properties: CBCharacteristicProperties.Notify, value: nil, permissions: CBAttributePermissions.Readable)
            let service = CBMutableService(type: CBUUID(NSUUID: uuid!), primary: true)
            service.characteristics = [writable, readable]
            
            print(service)

            peripheralManager!.addService(service)
            let data = [CBAdvertisementDataLocalNameKey : "iOS Chatter", CBAdvertisementDataServiceUUIDsKey : [CBUUID(NSUUID: uuid!)]]
            peripheralManager!.startAdvertising(data)
            print(data)

            print("Started advertising")

        } else {
            print(peripheralManager!.state.rawValue)
            print("Did not start advertising")
        }
    }

//    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
//        for beacon : CLBeacon in beacons {
//            print(beacon)
//        }
//    }
    
    internal func connectionTimer(timer:NSTimer){
        if (ble.peripherals != nil) {
            nearbyList = ble.peripherals! as NSArray as! [CBPeripheral]
            let notification = NSNotification(name: CommunicationNotification.NearbyListUpdated, object: nil, userInfo: nil)
            NSNotificationCenter.defaultCenter().postNotification(notification)
        }
    }
    
    func connectToUser(user:CBPeripheral) {
        ble.connectPeripheral(user)
    }
    
    func bleDidConnect() {
        NSLog("BLE Connected")
    }
    
    func bleDidDisconnect() {
        NSLog("BLE Disconnected")
    }
    
    func sendMessage(message : String!){
        let data = message.dataUsingEncoding(NSUTF8StringEncoding)
        if (ble.activePeripheral.state == CBPeripheralState.Connected){
            ble.write(data)
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest]) {
        print("Received write request")
        let request : CBATTRequest = requests[0]
        let requestData : NSData = request.value!
        let writeCharacteristics = request.characteristic
        
        var s = NSString(data: requestData, encoding: NSUTF8StringEncoding)
        print(s)
        
    }
    
    func bleDidReceiveData(data: UnsafeMutablePointer<UInt8>, length: Int32) {
        let d = NSData(bytes: data, length: Int(length))
        let s = NSString(data: d, encoding: NSUTF8StringEncoding)
        print(s)
        let message : JSQMessage = JSQMessage(senderId: ble.activePeripheral.identifier.UUIDString, senderDisplayName: ble.activePeripheral.name, date: NSDate(), text: s as? String)
        let not = NSNotification(name: CommunicationNotification.CentralReceivedMessage, object: nil, userInfo: ["message" : message])
        NSNotificationCenter.defaultCenter().postNotification(not)
    }
    
//    -(void) bleDidReceiveData:(unsigned char *)data length:(int)length
//    {
//    NSData *d = [NSData dataWithBytes:data length:length];
//    NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
//    NSLog(@"%@", s);
//    NSNumber *form = [NSNumber numberWithBool:YES];
//    
//    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:s, TEXT_STR, form, FORM, nil];
//    [tableData addObject:dict];
//    
//    [_tableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
//    [_tableView reloadData];
//    }

    
//    - (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
//    {
//    NSLog(@"didReceiveWriteRequests");
//    
//    CBATTRequest*       request = [requests  objectAtIndex: 0];
//    NSData*             request_data = request.value;
//    CBCharacteristic*   write_char = request.characteristic;
//    
//    uint8_t buf[request_data.length];
//    [request_data getBytes:buf length:request_data.length];
//    
//    NSMutableString *temp = [[NSMutableString alloc] init];
//    for (int i = 0; i < request_data.length; i++) {
//    [temp appendFormat:@"%c", buf[i]];
//    }
//    
//    if (str == nil) {
//    str = [NSMutableString stringWithFormat:@"%@\n", temp];
//    } else {
//    [str appendFormat:@"%@\n", temp];
//    }
//    
//    self.textView.text = str;
//    [self scrollOutputToBottom];
    
    //[peripheral respondToRequest:request withResult:CBATTErrorSuccess];
//    }
    
    func disconnect(){
        ble.disconnect()
    }
}

