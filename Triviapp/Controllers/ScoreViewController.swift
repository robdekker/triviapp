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
        
        performSegue(withIdentifier: "unwindToHome", sender: self)

    }
    
    // Properties
    var points = Int()
    var user: User!
    
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
