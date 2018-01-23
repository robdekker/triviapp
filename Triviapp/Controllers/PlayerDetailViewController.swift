//
//  PlayerDetailViewController.swift
//  Triviapp
//
//  Created by Rob Dekker on 18-01-18.
//  Copyright © 2018 Rob Dekker. All rights reserved.
//

import UIKit

class PlayerDetailViewController: UIViewController {

    // Outlets
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var dailyPointsLabel: UILabel!
    @IBOutlet weak var weeklyPointsLabel: UILabel!
    @IBOutlet weak var timesWonLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    
    // Properties
    var player: Player!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
    }
    
    func updateUI() {
        usernameLabel.text = player.username
        usernameLabel.adjustsFontSizeToFitWidth = true
        levelLabel.text = "Level: \(player.level)"
        dailyPointsLabel.text = "\(player.dailyPoints)"
        weeklyPointsLabel.text = "\(player.weeklyPoints)"
        timesWonLabel.text = "\(player.timesWon)"
        //profilePicture = ""
    
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
