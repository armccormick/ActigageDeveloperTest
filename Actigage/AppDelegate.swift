//
//  AppDelegate.swift
//  Actigage
//
//  Created by Anya on 20/08/2015.
//  Copyright (c) 2015 Anya. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let communicationManager = CommunicationManager.sharedInstance

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        var title : String? = ""
        
        if #available(iOS 8.2, *) {
            title = notification.alertTitle
        } else {
            title = "New Message"
        }
        let alert = UIAlertView(title: title, message: notification.alertBody, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }

//    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
//        print("changed state")
//        // We must construct a CLBeaconRegion that represents the payload we want the device to beacon.
//        print("Setting up beacon")
//        let uuid = NSUUID(UUIDString: "A8AA6B07-1485-4A0A-9FEC-468C8EF19ABC")
//        
//        if (uuid == nil) { print("uuid is nil") }
//        
//        let region = CLBeaconRegion(proximityUUID: uuid!, major: 42, minor: 666, identifier: "Actigage")
//        let peripheralData : NSDictionary = region.peripheralDataWithMeasuredPower(nil)
//
//        if (peripheralManager == nil) { print("uuid is nil") }
//        print(peripheralData)
//
//        // The region's peripheral data contains the CoreBluetooth-specific data we need to advertise.
//        print("Starting beacon")
//        if (peripheralManager!.state == CBPeripheralManagerState.PoweredOn){
//            peripheralManager!.startAdvertising((peripheralData as! [String : AnyObject]))
//            print("Started beacon")
//        } else {
//            print(peripheralManager!.state.rawValue)
//            print("Did not start beacon")
//        }
//    }

}

