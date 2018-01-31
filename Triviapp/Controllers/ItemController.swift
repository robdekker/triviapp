//
//  ItemController.swift
//  Triviapp
//
//  ItemController fetches questions from the API and decodes them immediately
//
//  Created by Rob Dekker on 15-01-18.
//  Copyright © 2018 Rob Dekker. All rights reserved.
//

import Foundation

class ItemController {
    
    static let shared = ItemController()
    
    let baseURL = URL(string: "https://opentdb.com/api.php?amount=10&difficulty=easy&type=multiple")!
    
    func fetchQuestions(completion: @escaping ([Question]?) -> Void) {
        var questions = [Question]()
        let questionURL = baseURL.appendingPathComponent("")
        let task = URLSession.shared.dataTask(with: questionURL) { (data, response, error) in
            if let data = data,
                let jsonDictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let fetchedQuestions = jsonDictionary!["results"] as? [[String: Any]] {
                for question in fetchedQuestions {
                    if let category = question["category"] as? String,
                        let type = question["type"] as? String,
                        let difficulty = question["difficulty"] as? String,
                        let theQuestion = question["question"] as? String,
                        let correctAnswer = question["correct_answer"] as? String,
                        let incorrectAnswers = question["incorrect_answers"] as? [String] {
                        
                        // Decode the questions and their corresponding answers
                        let theQuestionDecoded = theQuestion.htmlDecoded()
                        let correctAnswerDecoded = correctAnswer.htmlDecoded()
                        var incorrectAnswersDecoded = [String]()
                        for answer in incorrectAnswers {
                            let answerDecoded = answer.htmlDecoded()
                            incorrectAnswersDecoded.append(answerDecoded)
                        }
                        
                        questions.append(Question(category: category, type: type, difficulty: difficulty, question: theQuestionDecoded, correct_answer: correctAnswerDecoded, incorrect_answers: incorrectAnswersDecoded))
                    }
                }
                completion(questions)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
}

extension String {
    func htmlDecoded() -> String {
        
        guard (self != "") else { return self }
        
        var decodedString = self
        
        // From https://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references
        // A dictionary of HTML/XML entities
        let entities = [
            "&quot;"    : "\"",
            "&amp;"     : "&",
            "&#039;"    : "'",
            "&rsquo;"   : "'",
            "&lt;"      : "<",
            "&gt;"      : ">",
            "&deg;"     : "º",
            "&ntilde;"  : "ñ",
            "\u{0144}"  : "ń",
            "&aacute;"  : "á",
            "&eacute;"  : "é",
            "&ocirc;"   : "ô",
            "&oacute;"  : "ó",
            "&ouml;"    : "ö",
            "&Uuml;"    : "Ü",
            "&ldquo;"   : "\"",
            "&hellip;"  : "...",
            "&rdquo;"   : "\""
            ]
        
        for (name,value) in entities {
            decodedString = decodedString.replacingOccurrences(of: name, with: value)
        }
        return decodedString
    }
}
