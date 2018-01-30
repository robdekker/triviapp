//
//  Player.swift
//  Triviapp
//
//  Created by Rob Dekker on 16-01-18.
//  Copyright © 2018 Rob Dekker. All rights reserved.
//

import Foundation
import Firebase

struct Player {
    let username: String
    let level: Int
    let dailyPoints: Int
    let weeklyPoints: Int
    let timesWon: Int
    let imageURL: String
    let ref: DatabaseReference?
    
    init(username: String, level: Int, dailyPoints: Int, weeklyPoints: Int, timesWon: Int, imageURL: String) {
        self.username = username
        self.level = level
        self.dailyPoints = dailyPoints
        self.weeklyPoints = weeklyPoints
        self.timesWon = timesWon
        self.imageURL = imageURL
        self.ref = nil
    }
}
