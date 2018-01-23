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
    
    // Actions
    @IBAction func answerButtonTapped(_ sender: UIButton) {
        
        if sender.tag == rightAnswerPlacement {
            //sender.backgroundColor = .green
            print("Right!")
            points += 1
            
            let userID = Auth.auth().currentUser?.uid
            self.usersRef.child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user info
                let value = snapshot.value as? NSDictionary
                let dailyPoints = value?["daily_points"] as? Int ?? 0
                let weeklyPoints = value?["weekly_points"] as? Int ?? 0
                
                self.usersRef.child(userID!).updateChildValues([
                    "daily_points": dailyPoints + 1,
                    "weekly_points": weeklyPoints + 1
                    ])
                
            })

        } else {
            print("WRONG!")
        }
        
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
    
    // Constants
    let usersRef = Database.database().reference().child("users")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.tabBarController?.tabBar.isHidden = true
        newQuestion()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // New question
    func newQuestion() {
        self.navigationItem.title = "\(questionsDict[currentQuestion].category)"
        questionLabel.text = "\(questionsDict[currentQuestion].question)"
        rightAnswerPlacement = Int(arc4random_uniform(UInt32(3)))+1
        
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
        }
        currentQuestion += 1
        
        let timelineFrame = CGRect(x: 0, y: 0, width: 320, height: 25)
        let timeline = UIView(frame: timelineFrame)
        timeline.backgroundColor = .black

        timelineView.addSubview(timeline)
        
//        let animator = UIViewPropertyAnimator(duration: 20.0, curve: .linear) {
//            timeline.frame = CGRect(x: 0, y: 0, width: 0, height: 25)
//        }
//        animator.startAnimation()
//        animator.stopAnimation(true)
        
        UIView.animate(withDuration: 20.0, delay: 0.0, options: .curveLinear, animations: {
            timeline.frame = CGRect(x: 0, y: 0, width: 0, height: 25)
        }, completion: { finished in
            print("Time is up!")
            self.timeIsUp()
        })
    }
    
    func timeIsUp() {
        print("Function that says time is up!")
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showScore" {
            let scoreViewController = segue.destination as! ScoreViewController
            scoreViewController.points = points
        }
    }

}
