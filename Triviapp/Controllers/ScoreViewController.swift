//
//  ScoreViewController.swift
//  Triviapp
//
//  ScoreViewController represents the total amount of points the user has gathered with the quiz
//
//  Created by Rob Dekker on 18-01-18.
//  Copyright © 2018 Rob Dekker. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var scoreLabel: UILabel!
    
    // Actions
    @IBAction func backToHomeButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToHome", sender: self)
    }
    
    // Properties
    var points = Int()
    
    // Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    func updateUI() {
        self.navigationItem.hidesBackButton = true
        self.scoreLabel.text = "\(points)/10"

        var starImage: UIImageView = UIImageView()
        if self.points > 0 {
            // Amount of points is equal to amount of stars
            for tag in 1...self.points {
                // Usage of a delay for the stars to appear in order to smooth visualisation
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(0.2 * Double(tag))) {
                    starImage = self.view.viewWithTag(tag) as! UIImageView
                    starImage.image = UIImage(named: "star_rating")
                }
            }
        }
    }
}
