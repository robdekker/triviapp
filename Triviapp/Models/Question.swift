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
    let key: String
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
    let ref: DatabaseReference?
    
    init(key: String = "", category: String, type: String, difficulty: String, question: String, correct_answer: String, incorrect_answers: [String]) {
        //self.response_code = response_code
        self.key = key
        self.category = category
        self.type = type
        self.difficulty = difficulty
        self.question = question
        self.correct_answer = correct_answer
        self.incorrect_answers = incorrect_answers
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        category = snapshotValue["category"] as! String
        type = snapshotValue["type"] as! String
        difficulty = snapshotValue["difficulty"] as! String
        question = snapshotValue["question"] as! String
        correct_answer = snapshotValue["correct_answer"] as! String
        incorrect_answers = snapshotValue["incorrect_answers"] as! [String]
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "category": category,
            "type": type,
            "difficulty": difficulty,
            "question": question,
            "correct_answer": correct_answer,
            "incorrect_answers": incorrect_answers
        ]
    }
}
