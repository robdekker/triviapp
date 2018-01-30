//
//  QuestionViewController.swift
//  Triviapp
//
//  Created by Rob Dekker on 15-01-18.
//  Copyright © 2018 Rob Dekker. All rights reserved.
//

import UIKit
import Firebase
import QuartzCore

class QuestionViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var timelineView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var wrongOrRightLabel: UILabel!
    @IBOutlet weak var correctAnswerLabel: UILabel!
    
    // Actions
    @IBAction func answerButtonTapped(_ sender: UIButton) {
        showFeedback(boolean: true)
        
        if sender.tag == rightAnswerPlacement {
            print("Right!")
            self.view.backgroundColor = .green
            self.view.viewWithTag(5)?.backgroundColor = .green
            wrongOrRightLabel.text = "You are right!\nThe correct answer was:"
            points += 1
            
            self.usersRef.child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user info
                let value = snapshot.value as? NSDictionary
                let dailyPoints = value?["daily_points"] as? Int ?? 0
                let weeklyPoints = value?["weekly_points"] as? Int ?? 0
                
                self.usersRef.child(self.userID!).updateChildValues([
                    "daily_points": dailyPoints + 1,
                    "weekly_points": weeklyPoints + 1
                    ])
                
            })

        } else {
            print("WRONG!")
            self.view.backgroundColor = .red
            self.view.viewWithTag(5)?.backgroundColor = .red
            wrongOrRightLabel.text = "You are WRONG!\nThe correct answer was:"
        }
        
        timer.invalidate()
        
    }
    
    @IBAction func nextQuestionButtonTapped(_ sender: Any) {
        if currentQuestion != questionsDict.count {
            newQuestion()
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
    var lastTimeAnswered = String()
    
    // Constants
    let usersRef = Database.database().reference().child("users")
    let userID = Auth.auth().currentUser?.uid

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.tabBarController?.tabBar.isHidden = true
        showFeedback(boolean: false)
        newQuestion()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // New question
    func newQuestion() {
        seconds = 20
        self.navigationItem.title = "\(questionsDict[currentQuestion].category)"
        self.view.backgroundColor = .white
        questionLabel.text = "\(questionsDict[currentQuestion].question)"
        correctAnswerLabel.text = "\(questionsDict[currentQuestion].correct_answer)"
        timerLabel.text = "\(seconds)"
        rightAnswerPlacement = Int(arc4random_uniform(UInt32(3)))+1
        showFeedback(boolean: false)
        
        var button: UIButton = UIButton()
        
        var x = 0
        for tag in 1...4 {
            button = view.viewWithTag(tag) as! UIButton
            //button.backgroundColor = UIColor(red: 0, green: 122, blue: 255, alpha: 1.0)
            
            if tag == Int(rightAnswerPlacement) {
                button.setTitle(questionsDict[currentQuestion].correct_answer, for: .normal)
            } else {
                button.setTitle(questionsDict[currentQuestion].incorrect_answers[x], for: .normal)
                x += 1
            }
            button.titleEdgeInsets = UIEdgeInsetsMake(0,10,0,10)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.backgroundColor = UIColor(red: 66/255.0, green: 134/255.0, blue: 244/255.0, alpha: 1.0)

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
            print("Time is up!")
            wrongOrRightLabel.text = "Time is up!\nThe correct answer was:"
            wrongOrRightLabel.textColor = .black
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
        timeline.backgroundColor = .black
        timelineView.addSubview(timeline)
        
        UIView.animate(withDuration: 20.0, delay: 0.0, options: .curveLinear, animations: {
            timeline.frame = CGRect(x: 0, y: 0, width: 0, height: 25)
        }, completion: nil)
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showScore" {
            let scoreViewController = segue.destination as! ScoreViewController
            scoreViewController.points = points
        }
    }

}
