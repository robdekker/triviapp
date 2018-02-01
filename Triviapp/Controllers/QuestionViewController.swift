//
//  QuestionViewController.swift
//  Triviapp
//
//  QuestionViewController presents the questions with their corresponding answers to the user
//  When the user answers the question, the user will receive feedback
//
//  Created by Rob Dekker on 15-01-18.
//  Copyright © 2018 Rob Dekker. All rights reserved.
//

import UIKit
import Firebase

class QuestionViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var timelineView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var wrongOrRightLabel: UILabel!
    @IBOutlet weak var correctAnswerLabel: UILabel!
    @IBOutlet weak var nextQuestionButton: UIButton!
    @IBOutlet weak var checkmarkImage: UIImageView!
    
    // Actions
    @IBAction func answerButtonTapped(_ sender: UIButton) {
        showFeedback(boolean: true)
        
        if sender.tag == rightAnswerPlacement {
            checkmarkImage.image = UIImage(named: "green_checkmark")
            wrongOrRightLabel.text = "You are right!\nThe correct answer was:"
            points += 1
            
            self.usersRef.child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user info and add 1 points to both daily and weekly score
                let value = snapshot.value as? NSDictionary
                let dailyPoints = value?["daily_points"] as? Int ?? 0
                let weeklyPoints = value?["weekly_points"] as? Int ?? 0
                let totalPoints = value?["total_points"] as? Int ?? 0
                
                self.usersRef.child(self.userID!).updateChildValues([
                    "daily_points": dailyPoints + 1,
                    "weekly_points": weeklyPoints + 1,
                    "total_points": totalPoints + 1,
                    "level": self.updateLevel(points: totalPoints + 1)
                ])
            })

        } else {
            checkmarkImage.image = UIImage(named: "red_checkmark")
            wrongOrRightLabel.text = "You are WRONG!\nThe correct answer was:"
        }
        
        timer.invalidate()
    }
    
    @IBAction func nextQuestionButtonTapped(_ sender: Any) {
        // As long as there are questions, show next question
        if currentQuestion != questionsDict.count {
            newQuestion()

        // No questions left
        } else {
            performSegue(withIdentifier: "showScore", sender: self)
        }
    }
    
    // Properties
    var questionsDict = [Question]()
    var currentQuestion = 0
    var rightAnswerPlacement = 0
    var points = 0
    var seconds = 20
    var timer = Timer()
    
    // Constants
    let usersRef = Database.database().reference().child("users")
    let userID = Auth.auth().currentUser?.uid

    // Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        showFeedback(boolean: false)
        newQuestion()
    }
    
    func updateLevel(points: Int) -> Int {
        let level = points / 100
        return level
    }
    
    func updateUI() {
        self.navigationItem.hidesBackButton = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func newQuestion() {
        seconds = 20
        self.navigationItem.title = "\(questionsDict[currentQuestion].category)"
        questionLabel.text = "\(questionsDict[currentQuestion].question)"
        correctAnswerLabel.text = "\(questionsDict[currentQuestion].correct_answer)"
        timerLabel.text = "\(seconds)"
        rightAnswerPlacement = Int(arc4random_uniform(UInt32(3)))+1
        showFeedback(boolean: false)
        
        var button: UIButton = UIButton()
        
        // The variable 'x' will loop through the incorrect answers
        var x = 0
        for tag in 1...4 {
            button = view.viewWithTag(tag) as! UIButton
            
            if tag == Int(rightAnswerPlacement) {
                button.setTitle(questionsDict[currentQuestion].correct_answer, for: .normal)
            } else {
                button.setTitle(questionsDict[currentQuestion].incorrect_answers[x], for: .normal)
                x += 1
            }
            button.titleEdgeInsets = UIEdgeInsetsMake(0,10,0,10)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.textColor = UIColor(red: 243/255.0, green:105/255.0, blue: 0/255.0, alpha: 1.0)
            button.backgroundColor = UIColor(red: 60/255.0, green: 86/255.0, blue: 156/255.0, alpha: 1.0)
        }
        currentQuestion += 1
        startAnimation()
        runTimer()
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(QuestionViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if seconds < 1 {
            timer.invalidate()
            checkmarkImage.image = UIImage(named: "red_checkmark")
            wrongOrRightLabel.text = "Time is up!\nThe correct answer was:"
            showFeedback(boolean: true)
        } else {
            seconds -= 1
            timerLabel.text = "\(seconds)"
        }
    }
    
    func showFeedback(boolean: Bool) {
        // View with tag 5: view with feedback and correct answer
        view.viewWithTag(5)?.isHidden = !boolean
        // View with tag 6: timeline view
        view.viewWithTag(6)?.isHidden = boolean
        // View with tag 7: view with answer buttons
        view.viewWithTag(7)?.isHidden = boolean
    }
    
    func startAnimation() {
        let timelineFrame = CGRect(x: 0, y: 0, width: 320, height: 25)
        let timeline = UIView(frame: timelineFrame)
        timeline.backgroundColor = UIColor(red: 243/255.0, green:105/255.0, blue: 0/255.0, alpha: 1.0)
        timelineView.addSubview(timeline)
        
        UIView.animate(withDuration: 20.0, delay: 0.0, options: .curveLinear, animations: {
            timeline.frame = CGRect(x: 0, y: 0, width: 0, height: 25)
        }, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showScore" {
            let scoreViewController = segue.destination as! ScoreViewController
            scoreViewController.points = points
        }
    }
}
