//
//  HomeViewController.swift
//  Triviapp
//
//  Created by Rob Dekker on 12-01-18.
//  Copyright © 2018 Rob Dekker. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {

    // Outlets
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var questionsToPlayLabel: UILabel!
    @IBOutlet weak var startQuizButton: UIButton!
    
    // Actions
    @IBAction func startQuizButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "startQuiz", sender: self)
    }
    
    // Properties
    var user: User!
    var currentUserRef = Database.database().reference().child("users")
    var questionsRef = Database.database().reference().child("questions")
    var questions = [Question]()
    var newQuestions = [String: Any]()
    var lastTimeAnswered = String()
    
    // Constants
    let userID = Auth.auth().currentUser?.uid
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.currentUserRef.child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user info
            let value = snapshot.value as? NSDictionary
            let username = value?["username"] as? String ?? "Unknown user"
            let level = value?["level"] as? Int ?? 0
            self.lastTimeAnswered = value?["lastTimeAnswered"] as? String ?? "Unknown"
            
            // Set labels
            self.usernameLabel.text = username
            self.usernameLabel.adjustsFontSizeToFitWidth = true
            self.levelLabel.text = "Level: \(level)"
        })
        
        loadQuestions()
    }
    
    func updateUI(with questions: [Question]) {
        DispatchQueue.main.async {
            self.questions = questions
            self.questionsToPlayLabel.text = "You have \(questions.count) questions waiting for you today!"
        }
    }
    
    func loadQuestions() {
        self.questionsRef.observe(.value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
//            let questionsDict = value?["questions"] as? [[String: Any]]
//            for question in questionsDict {
//                if let category = question["category"] as? String,
//                    let type = question["type"] as? String,
//                    let difficulty = question["difficulty"] as? String,
//                    let theQuestion = question["question"] as? String,
//                    let correctAnswer = question["correct_answer"] as? String,
//                    let incorrectAnswers = question["incorrect_answers"] as? [String] {
//                    self.questions.append(Question(category: category, type: type, difficulty: difficulty, question: theQuestion, correct_answer: correctAnswer, incorrect_answers: incorrectAnswers))
//                }
//            }
            let date = value?["date"] as! String
            let currentDate = String(describing: HomeViewController.dateFormatter.string(from: Date()))
            let currentWeekday = Calendar.current.component(.weekday, from: Date())

            self.fetchOrLoadQuestions(questions: self.questions, date: date, currentDate: currentDate, currentWeekday: currentWeekday)
            
        })
    }
    
    func fetchOrLoadQuestions(questions: [Question], date: String, currentDate: String, currentWeekday: Int) {
        // There are questions in Firebase
        // if questions?.count == 10 {
        if questions.count == 10 {
            print("There are questions in Firebase")
            // If current week day is monday
            if currentWeekday == 2 {
                print("It is monday, so a new week begins: new game, new chances")
                print("Let's reset all daily and weekly points of all players!")
                // Reset daily and weekly points of all players to 0
                self.currentUserRef.observe(.value, with: { snapshot in
                    let usersDict = snapshot.value as? [String : AnyObject] ?? [:]
    
                    for user in usersDict {
                        self.currentUserRef.child(user.key).updateChildValues([
                            "daily_points": 0,
                            "weekly_points": 0,
                        ])
                    }
                    print("Daily and weekly points of all players reset")
                })
    
                // Get new data from API
                ItemController.shared.fetchQuestions { (questions) in
                    if let questions = questions {
                        //let questionsFirebase = questions.toAnyObject()
                        self.questionsRef.setValue([
                            //"questions": 10,
                            "date": currentDate,
                            "weekday": 0
                        ])
                        self.updateUI(with: questions)
                    }
                }
            // If current week day is any other day than monday
            } else {
                // Date when questions where fetched is today
                if date.isEqual(currentDate) == true {
                    // When you have not yet answered the questions for today
                    if self.lastTimeAnswered.isEqual(currentDate) != true {
                        print("Questions for today are in Firebase but not answered.")
                        print("Let's get the questions from Firebase!")
                        self.updateUI(with: questions)
                        self.questionsToPlayLabel.text = "You have \(questions.count) questions left to play!"
                        // When you already have answered the questions for today
                    } else {
                        print("Questions for today are in Firebase and already answered.")
                        self.questionsToPlayLabel.text = "NO questions to play."
                        self.startQuizButton.backgroundColor = .darkGray
                        self.startQuizButton.isEnabled = false
                    }
                // Date when questions where fetched is not today
                } else {
                    print("Questions not yet fetched by a player, get these from the API!")
                    // Get new data from API
                    ItemController.shared.fetchQuestions { (questions) in
                        if let questions = questions {
                            self.questions = questions
                            self.updateUI(with: questions)
                        }
                    
                        var count = 1
                        var newQuestions = [String: Any]()
                        for question in self.questions {
                            newQuestions["Question \(count)"] = question.toAnyObject()
                            count += 1
                        }
                        print("newQuestions:", newQuestions)
                    }
                    
                    self.questionsRef.setValue([
                        "questions": newQuestions,
                        "date": currentDate,
                        "weekday": currentWeekday
                        ])
                    }
                }
            
        // No questions in Firebase (only first time)
        } else {
            print("No questions fetched for today! Let's fetch questions now!")
            // Get data from API
            ItemController.shared.fetchQuestions { (questions) in
                if let questions = questions {
                    self.questions = questions
                    self.updateUI(with: questions)
                }
                
                var count = 1
                for question in self.questions {
                    self.newQuestions["Question \(count)"] = question.toAnyObject()
                    count += 1
                }
            
                self.questionsRef.setValue([
                    "questions": self.newQuestions,
                    "date": currentDate,
                    "weekday": currentWeekday
                ])
            }
        }
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//
//        UIView.animate(withDuration: 2.0, delay: 0.0, options: .repeat, animations: {
//            self.startQuizButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
//        },
//                       completion: { _ in
//                        UIView.animate(withDuration: 2.0, animations: {
//                            self.startQuizButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
//                        })
//        })
//
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "startQuiz" {
            let questionViewController = segue.destination as! QuestionViewController
            questionViewController.questionsDict = questions
        }
    }
}
