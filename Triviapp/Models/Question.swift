//
//  Question.swift
//  Triviapp
//
//  Created by Rob Dekker on 15-01-18.
//  Copyright © 2018 Rob Dekker. All rights reserved.
//

import Foundation
import Firebase

struct Question {
    //let response_code: Int
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
    let ref: DatabaseReference?
    
    init(category: String, type: String, difficulty: String, question: String, correct_answer: String, incorrect_answers: [String]) {
        //self.response_code = response_code
        self.category = category
        self.type = type
        self.difficulty = difficulty
        self.question = question
        self.correct_answer = correct_answer
        self.incorrect_answers = incorrect_answers
        self.ref = nil
    }
}
