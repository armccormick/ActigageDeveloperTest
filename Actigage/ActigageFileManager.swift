//
//  DataManager.swift
//  Actigage
//
//  Created by Anya on 23/08/2015.
//  Copyright © 2015 Anya. All rights reserved.
//

import Foundation

public enum ActigageDataKey : String {
    case MessageHistory = "kActigageDataKeyMessageHistory"
    case UserDisplayName = "kActigageDataKeyUserDisplayName"
}


class ActigageFileManager : NSFileManager {
    static let sharedInstance = ActigageFileManager()

    var archivePath : NSURL?

    override init() {
        super.init()
        
        let paths = self.URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        let appSupportDirectory = paths[0]
        archivePath = appSupportDirectory.URLByAppendingPathComponent(NSBundle.mainBundle().bundleIdentifier!)
        
        if (!self.fileExistsAtPath((appSupportDirectory.path)!)){
            do {
                try self.createDirectoryAtPath((appSupportDirectory.path)!, withIntermediateDirectories: true, attributes: nil)
                print(self.fileExistsAtPath(appSupportDirectory.path!))
                
            } catch let e as NSError {
                NSLog("Problem creating App Support directory: %@", e)
            }
        }
        if (!self.fileExistsAtPath((archivePath?.path)!)){
            self.createFileAtPath(archivePath!.path!, contents: nil, attributes: nil)
        }
    }
    
    // Save data to disk for the given key
    func saveData(object : AnyObject?, key: ActigageDataKey) -> Bool {
        var data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(object, forKey: key.rawValue)
        archiver.finishEncoding()
                
        do {
            try data.writeToURL(archivePath!, options: NSDataWritingOptions.DataWritingAtomic)
            return true
            
        } catch let error as NSError {
            print(error)
            return false
        }
    }
    
    // Retrieve data previously saved in the given key
    func retrieveData(key: ActigageDataKey) -> AnyObject? {
        let data = NSData(contentsOfURL: archivePath!)
        if (data == nil){
            return nil
        }
        let unarchiver = NSKeyedUnarchiver(forReadingWithData: data!)
        let o = unarchiver.decodeObjectForKey(key.rawValue)
        unarchiver.finishDecoding()
        return o
    }
}
