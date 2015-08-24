//
//  User.swift
//  Actigage
//
//  Created by Anya on 24/08/2015.
//  Copyright © 2015 Anya. All rights reserved.
//

import Foundation

class UserChatHistory : NSObject, NSCoding {
    var user : User!
    var messages : [JSQMessage] = []
    
    override init() {}
    
    init(uuid: String!, displayName: String!) {
        super.init()
        self.user = User(uuid: uuid, displayName: displayName)
    }
    
    @objc required init?(coder aDecoder: NSCoder) {
        user = aDecoder.decodeObjectForKey("user") as! User
        messages = aDecoder.decodeObjectForKey("messages") as! [JSQMessage]
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(user, forKey: "user")
        aCoder.encodeObject(messages, forKey: "messages")
    }
}