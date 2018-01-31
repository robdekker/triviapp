//
//  Player.swift
//  Triviapp
//
//  Player.swift is a struct that represents other users than the current User
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
    let totalPoints: Int
    let imageURL: String
    let ref: DatabaseReference?
    
    init(username: String, level: Int, dailyPoints: Int, weeklyPoints: Int, totalPoints: Int, imageURL: String) {
        self.username = username
        self.level = level
        self.dailyPoints = dailyPoints
        self.weeklyPoints = weeklyPoints
        self.totalPoints = totalPoints
        self.imageURL = imageURL
        self.ref = nil
    }
}
