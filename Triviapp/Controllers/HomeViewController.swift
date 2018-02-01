//
//  HomeViewController.swift
//  Triviapp
//
//  HomeViewController checks various variables in order to determine if the user has still some
//  questions to play, or if the user needs to fetch questions from the API
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
    @IBOutlet weak var fingerPointer: UIImageView!
    
    // Actions
    @IBAction func startQuizButtonTapped(_ sender: Any) {
        let currentDate = Date()
        lastTimeAnswered = HomeViewController.dateFormatter.string(from: currentDate)
        
        self.usersRef.child(userID!).updateChildValues([
            "lastTimeAnswered": lastTimeAnswered
            ])
        performSegue(withIdentifier: "startQuiz", sender: self)
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        self.tabBarController?.selectedIndex = 0
    }
    
    // Properties
    var user: User!
    var usersRef = Database.database().reference().child("users")
    var dateRef = Database.database().reference().child("questions")
    var questionsRef = Database.database().reference().child("questions").child("questions")
    var lastResetRef = Database.database().reference().child("lastResetDate")
    var questions = [Question]()
    var date = String()
    var currentDate = String()
    var currentWeekday = Int()
    var newQuestions = [String: Any]()
    var lastTimeAnswered = String()
    var lastResetDate = String()
    
    // Constants
    let userID = Auth.auth().currentUser?.uid
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    // Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        getFirebaseData()
        usersRef.keepSynced(true)
        dateRef.keepSynced(true)
        loadFirebaseData()
    }
    
    func getFirebaseData() {
        self.navigationController?.navigationBar.titleTextAttributes = [ .font: UIFont(name: "HVDComicSerifPro", size: 20)!, .foregroundColor: UIColor.white ]
        
        self.usersRef.child(userID!).observeSingleEvent(of: .value, with: { snapshot in
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 2.0, delay: 0.0, options: .repeat, animations: {
            self.fingerPointer.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: { _ in
            UIView.animate(withDuration: 2.0, animations: {
                self.fingerPointer.transform = CGAffineTransform.identity
            })
        })
    }
    
    func updateUI(with questions: [Question]) {
        DispatchQueue.main.async {
            self.questions = questions
            self.questionsToPlayLabel.text = "You have \(questions.count) questions waiting for you today!"
            self.startQuizButton.setTitle("Start quiz", for: .normal)
            self.startQuizButton.backgroundColor = UIColor(red: 243/255.0, green:105/255.0, blue: 0/255.0, alpha: 1.0)
            self.startQuizButton.isEnabled = true
        }
    }
    
    func loadFirebaseData() {
        self.questionsRef.observe(.value, with: { snapshot in
            if snapshot.exists() {
                for item in snapshot.children {
                    let question = Question(snapshot: item as! DataSnapshot)
                    self.questions.append(question)
                }
            }
        })
        
        self.lastResetRef.observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? String
            self.lastResetDate = value!
        })
        
        self.dateRef.observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            self.date = value?["date"] as! String
            self.currentDate = String(describing: HomeViewController.dateFormatter.string(from: Date()))
            self.currentWeekday = Calendar.current.component(.weekday, from: Date())

            self.fetchOrLoadQuestions(questions: self.questions, date: self.date, currentDate: self.currentDate, currentWeekday: self.currentWeekday)
        })
    }
    
    func fetchOrLoadQuestions(questions: [Question], date: String, currentDate: String, currentWeekday: Int) {
        // There are questions in Firebase
        if questions.count == 10 {
            // If current week day is monday
            if currentWeekday == 2 && self.lastResetDate != self.currentDate {
                // Reset daily and weekly points of all players to 0
                self.usersRef.observe(.value, with: { snapshot in
                    let usersDict = snapshot.value as? [String : AnyObject] ?? [:]
    
                    for user in usersDict {
                        self.usersRef.child(user.key).updateChildValues([
                            "daily_points": 0,
                            "weekly_points": 0,
                        ])
                    }
                })
                self.lastResetRef.setValue(self.currentDate)
                
                // Get new data from API
                fetchQuestions()
                
            // If current week day is any other day than monday
            } else {
                // Date when questions where fetched is today
                if date.isEqual(currentDate) == true {
                    // When you have not yet answered the questions for today
                    if self.lastTimeAnswered.isEqual(currentDate) != true {
                        self.updateUI(with: questions)
                    // When you already have answered the questions for today
                    } else {
                        self.questionsToPlayLabel.text = "NO questions to play."
                        self.startQuizButton.backgroundColor = .darkGray
                        self.startQuizButton.setTitle("No quiz", for: .normal)
                        self.startQuizButton.isEnabled = false
                        self.fingerPointer.isHidden = true
                    }
                // Date when questions where fetched is not today
                } else {
                    // Get new data from API
                    fetchQuestions()
                    
                    // Reset daily points of all players
                    self.usersRef.observe(.value, with: { snapshot in
                        let usersDict = snapshot.value as? [String : AnyObject] ?? [:]
                        
                        for user in usersDict {
                            self.usersRef.child(user.key).updateChildValues([
                                "daily_points": 0
                                ])
                        }
                    })
                }
            }
            
        // No questions in Firebase (only first time)
        } else {
            // Get data from API
            fetchQuestions()
        }
    }
    
    func fetchQuestions() {
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
            
            self.dateRef.updateChildValues([
                "questions": self.newQuestions,
                "date": self.currentDate,
                "weekday": self.currentWeekday
                ])
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startQuiz" {
            let questionViewController = segue.destination as! QuestionViewController
            questionViewController.questionsDict = questions
        }
    }
}
