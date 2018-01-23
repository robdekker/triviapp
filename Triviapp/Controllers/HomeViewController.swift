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
    var questions = [Question]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let userID = Auth.auth().currentUser?.uid
        currentUserRef.child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user info
            let value = snapshot.value as? NSDictionary
            let username = value?["username"] as? String ?? "Unknown user"
            let level = value?["level"] as? Int ?? 0
            
            // Set labels
            self.usernameLabel.text = username
            self.usernameLabel.adjustsFontSizeToFitWidth = true
            self.levelLabel.text = "Level: \(level)"
        })
        
        // Get data from API
        ItemController.shared.fetchQuestions { (questions) in
            if let questions = questions {
                self.updateUI(with: questions)
            }
        }
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
