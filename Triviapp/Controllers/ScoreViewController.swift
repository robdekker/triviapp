//
//  ScoreViewController.swift
//  Triviapp
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
        
        //navigationController?.popToRootViewController(animated: true)
        performSegue(withIdentifier: "unwindToHome", sender: self)

    }
    
    // Properties
    var points = Int()
    
    // Constants
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true
        scoreLabel.text = "Score: \(points)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToHome" {
            let loginViewController = segue.destination as! LoginViewController
            loginViewController.previousViewController = "ScoreViewController"
        }
    }

}
