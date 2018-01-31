//
//  ProfileViewController.swift
//  Triviapp
//
//  ProfileViewController shows all properties of the selected or current user
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
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var backgroundProfileImage: UIImageView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    func updateUI() {
        self.navigationController?.navigationBar.titleTextAttributes = [ .font: UIFont(name: "HVDComicSerifPro", size: 20)!, .foregroundColor: UIColor.white ]
        // It is another user than the current user
        if player != nil {
            self.navigationItem.rightBarButtonItem = nil

            self.usernameLabel.text = player.username
            self.usernameLabel.textColor = .black
            self.levelLabel.text = "Level: \(player.level)"
            self.usernameLabel.textColor = .black
            self.dailyPointsLabel.text = "\(player.dailyPoints)"
            self.weeklyPointsLabel.text = "\(player.weeklyPoints)"
            
            if player.imageURL != "default_profile" {
                let url = URL(string: "\(player.imageURL)")
                self.backgroundProfileImage.kf.setImage(with: url)
                self.profileImage!.kf.setImage(with: url)
            } else {
                self.profileImage!.image = UIImage(named: "\(player.imageURL)")
            }
        
        // Update labels to info of current user
        } else {

            let userID = Auth.auth().currentUser?.uid

            self.usersRef.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user info
                let value = snapshot.value as? NSDictionary
                let username = value?["username"] as? String ?? "Unknown user"
                let level = value?["level"] as? Int ?? 0
                let dailyPoints = value?["daily_points"] as? Int ?? 0
                let weeklyPoints = value?["weekly_points"] as? Int ?? 0
                let url = URL(string: "\(value?["imageURL"] ?? "default_profile")")
                
                // Set labels retrieved from Firebase
                self.usernameLabel.text = username
                self.levelLabel.text = "Level: \(level)"
                self.dailyPointsLabel.text = "\(dailyPoints)"
                self.weeklyPointsLabel.text = "\(weeklyPoints)"
                
                // Use KingFisher to download and cache the image
                self.backgroundProfileImage.kf.setImage(with: url)
                self.profileImage.kf.setImage(with: url)
            })
        }
        self.usernameLabel.adjustsFontSizeToFitWidth = true
        self.profileImage!.layer.borderWidth = 1
        self.profileImage!.layer.masksToBounds = false
        self.profileImage!.layer.borderColor = UIColor.black.cgColor
        self.profileImage!.layer.cornerRadius = self.profileImage!.frame.height/2
        self.profileImage!.clipsToBounds = true
        self.addBlur(image: self.backgroundProfileImage)
    }
    
    // Add blur to background profile image
    func addBlur(image: UIImageView) {
        let blurEffect = UIBlurEffect(style: .light)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurredEffectView.frame = image.bounds
        image.addSubview(blurredEffectView)
    }
}
