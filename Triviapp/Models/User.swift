//
//  User.swift
//  Triviapp
//
//  User.swift creates a struct that will represent the user
//
//  Created by Rob Dekker on 11-01-18.
//  Copyright © 2018 Rob Dekker. All rights reserved.
//

import Foundation
import Firebase

struct User {
    
    let uid: String!
    let email: String!
    
    init(authData: Firebase.User) {
        uid = authData.uid
        email = authData.email!
    }
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
}
