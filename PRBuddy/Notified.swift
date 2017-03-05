//
//  User.swift
//  PRBuddy
//
//  Created by Thang on 30.12.2016.
//  Copyright © 2016 Thangphan. All rights reserved.
//

import Foundation
import UIKit

class Notified: NSObject{
    
    var userUsername: String! = ""
    var userFirstname: String! = ""
    var userLastname: String! = ""
    var userDescription: String = ""
    var userScore: Double!
    var userUserID: String! = ""
    var userPushtoken: String! = ""
    var userVoteCount: Int!
    var userRawScore: Double!
    
    init(username: String, firstname: String, lastname: String, score: Double, description: String, userid: String, pushtoken: String, votecount: Int, rawscore: Double) {
        self.userUsername = username
        self.userFirstname = firstname
        self.userLastname = lastname
        self.userScore = score
        self.userDescription = description
        self.userUserID = userid
        self.userPushtoken = pushtoken
        self.userVoteCount = votecount
        self.userRawScore = rawscore
    }
}
