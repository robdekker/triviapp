//
//  Question.swift
//  Triviapp
//
//  Question.swift is a struct that represents the type of a question
//
//  Created by Rob Dekker on 15-01-18.
//  Copyright © 2018 Rob Dekker. All rights reserved.
//

import Foundation
import Firebase

struct Question {
    let key: String
    let category: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
    let ref: DatabaseReference?
    
    init(key: String = "", category: String, question: String, correct_answer: String, incorrect_answers: [String]) {
        self.key = key
        self.category = category
        self.question = question
        self.correct_answer = correct_answer
        self.incorrect_answers = incorrect_answers
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        category = snapshotValue["category"] as! String
        question = snapshotValue["question"] as! String
        correct_answer = snapshotValue["correct_answer"] as! String
        incorrect_answers = snapshotValue["incorrect_answers"] as! [String]
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "category": category,
            "question": question,
            "correct_answer": correct_answer,
            "incorrect_answers": incorrect_answers
        ]
    }
}
