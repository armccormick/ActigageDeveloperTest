//
//  User.swift
//  Actigage
//
//  Created by Anya on 24/08/2015.
//  Copyright © 2015 Anya. All rights reserved.
//

import Foundation

class User : NSObject, NSCoding {
    var uuid : String!
    var displayName : String!

    init(uuid: String!, displayName: String!) {
        super.init()
        self.uuid = uuid
        self.displayName = displayName
    }

    @objc required init?(coder aDecoder: NSCoder) {
        uuid = aDecoder.decodeObjectForKey("uuid") as! String
        displayName = aDecoder.decodeObjectForKey("displayName") as! String
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(uuid, forKey: "uuid")
        aCoder.encodeObject(displayName, forKey: "displayName")
    }

}