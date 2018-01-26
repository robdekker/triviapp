//
//  ProfileViewController.swift
//  Triviapp
//
//  Created by Rob Dekker on 12-01-18.
//  Copyright © 2018 Rob Dekker. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import Kingfisher

class ProfileViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var dailyPointsLabel: UILabel!
    @IBOutlet weak var weeklyPointsLabel: UILabel!
    @IBOutlet weak var timesWonLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
        
    // Actions
    @IBAction func signOutButtonTapped(_ sender: Any) {
        do {
            if FBSDKAccessToken.current() != nil {
                
                FBSDKLoginManager().logOut()
                print("Facebook account logged out")
                
            } else {
                
                try Auth.auth().signOut()
                print("Normal account logged out")
            }
            
            performSegue(withIdentifier: "unwindToLogin", sender: self)
        
        } catch {
            print("Error logging out")
        }
    }
    
    // Properties
    var user: User!
    var usersRef = Database.database().reference()
    var player: Player!

    // Constants
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUI() {
        if player != nil {
            self.navigationItem.rightBarButtonItem = nil

            self.usernameLabel.text = player.username
            self.usernameLabel.adjustsFontSizeToFitWidth = true
            self.levelLabel.text = "Level: \(player.level)"
            self.dailyPointsLabel.text = "\(player.dailyPoints)"
            self.weeklyPointsLabel.text = "\(player.weeklyPoints)"
            self.timesWonLabel.text = "\(player.timesWon)"
            //profilePicture = ""
            
        } else {
        
            let userID = Auth.auth().currentUser?.uid

            self.usersRef.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user info
                let value = snapshot.value as? NSDictionary
                let username = value?["username"] as? String ?? "Unknown user"
                let level = value?["level"] as? Int ?? 0
                let dailyPoints = value?["daily_points"] as? Int ?? 0
                let weeklyPoints = value?["weekly_points"] as? Int ?? 0
                let timesWon = value?["times_won"] as? Int ?? 0
                let url = URL(string: "\(value?["image"] ?? "default_profile")")
                
                // Set labels retrieved from Firebase
                self.usernameLabel.text = username
                self.usernameLabel.adjustsFontSizeToFitWidth = true
                self.levelLabel.text = "Level: \(level)"
                self.dailyPointsLabel.text = "\(dailyPoints)"
                self.weeklyPointsLabel.text = "\(weeklyPoints)"
                self.timesWonLabel.text = "\(timesWon)"
                
                // Use KingFisher to download and cache the image
                self.profilePicture.kf.setImage(with: url)
                self.profilePicture.layer.borderWidth = 1
                self.profilePicture.layer.masksToBounds = false
                self.profilePicture.layer.borderColor = UIColor.black.cgColor
                self.profilePicture.layer.cornerRadius = self.profilePicture.frame.height/2
                self.profilePicture.clipsToBounds = true
                
            }) { (error) in
                print(error.localizedDescription)
            }
        }
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
