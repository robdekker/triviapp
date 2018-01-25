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

        currentUserRef.child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user info
            let value = snapshot.value as? NSDictionary
            let username = value?["username"] as? String ?? "Unknown user"
            let level = value?["level"] as? Int ?? 0
            let lastTimeAnswered = value?["lastTimeAnswered"] as? String ?? "Unknown"
            
            // Set labels
            self.usernameLabel.text = username
            self.usernameLabel.adjustsFontSizeToFitWidth = true
            self.levelLabel.text = "Level: \(level)"
        //})
        
        self.questionsRef.observe(.value, with: { snapshot in
            let questionsDict = snapshot.value as? [String : AnyObject] ?? [:]
            print("Questions dict:", questionsDict)
            let questions = questionsDict["questions"]
            let date = questionsDict["date"]
            let currentDate = Date()
            let currentDateFormatted = HomeViewController.dateFormatter.string(from: currentDate)
            let calendar = Calendar.current
            let weekday = calendar.component(.weekday, from: currentDate)
            
            if questions?.count == 10 {
                print("Questions already fetched")
                if date?.isEqual(currentDate) != true {
                    if lastTimeAnswered.isEqual(currentDate) != true {
                        print("Questions for today are fetched but not answered.")
                        // Get data from API
//                        ItemController.shared.fetchQuestions { (questions) in
//                            if let questions = questions {
//                                self.questionsRef.updateChildValues([
//                                    //"questions": questions,
//                                    "date": currentDateFormatted
//                                    ])
                        self.updateUI(with: questions as! [Question])
//                            }
//                        }
                    } else {
                        print("Questions are fetched and already answered.")
                        self.questionsToPlayLabel.text = "NO questions to play."
                        self.startQuizButton.backgroundColor = .darkGray
                        self.startQuizButton.isEnabled = false
                    }
                    
                } else {
                    print("Questions already fetched by a player, get these from firebase IF YOU HAVEN'T ANSWERED THEM YET!")
                    self.updateUI(with: questions as! [Question])

                }
            } else {
                print("No questions fetched for today!")
                // Get data from API
                ItemController.shared.fetchQuestions { (questions) in
                    if let questions = questions {
                        print("Works 1")
                        self.questionsRef.setValue([
                            //"questions": questions,
                            "date": currentDateFormatted,
                            "weekday": weekday
                            ])
                        print("Works 2")
                        self.updateUI(with: questions)
                        print("Works 3")
                        
                        // Reset daily points of all players to 0
                        self.currentUserRef.observe(.value, with: { snapshot in
                            let usersDict = snapshot.value as? [String : AnyObject] ?? [:]

                            for user in usersDict {
                                self.currentUserRef.child(user.key).updateChildValues([
                                    "daily_points": 0
                                ])
                            }
                            print("Daily points of all users reset")
                        })
                    }
                }
            }
            
        })
        })
    }
    
    func updateUI(with questions: [Question]) {
        DispatchQueue.main.async {
            self.questions = questions
            self.questionsToPlayLabel.text = "You have \(questions.count) questions waiting for you today!"
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
