//
//  LeaderboardTableViewController.swift
//  Triviapp
//
//  LeaderboardTableViewController shows the top 10 daily and weekly users
//  According to the selected index of the segmented control
//
//  Created by Rob Dekker on 15-01-18.
//  Copyright © 2018 Rob Dekker. All rights reserved.
//

import UIKit
import Firebase

class LeaderboardTableViewController: UITableViewController {
    
    // Outlets
    @IBOutlet weak var leaderboardSegmentedControl: UISegmentedControl!
    @IBOutlet weak var leaderboardTableView: UITableView!
    
    // Actions
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        self.leaderboardTableView.reloadData()
    }
    
    // Properties
    var dailyTopPlayers = [Player]()
    var weeklyTopPlayers = [Player]()
    
    // Constants
    let usersRef = Database.database().reference(withPath: "users")
    
    // Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        usersRef.keepSynced(true)
        getDailyTopPlayers()
        getWeeklyTopPlayers()
    }
    
    func updateUI() {
        self.leaderboardTableView.rowHeight = 45.5
        self.leaderboardTableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    func getDailyTopPlayers() {
        usersRef.queryOrdered(byChild: "daily_points").queryLimited(toLast: 10).observe(.value, with: { snapshot in
            var newDailyPlayers: [Player] = []
            
            let playerDict = snapshot.value as? [String : AnyObject] ?? [:]
            for player in playerDict {
                let attributes = player.value
                let username = attributes["username"]
                let level = attributes["level"]
                let dailyPoints = attributes["daily_points"]
                let weeklyPoints = attributes["weekly_points"]
                let totalPoints = attributes["total_points"]
                let imageURL = attributes["imageURL"]
                
                let playerItem = Player(username: username as! String,
                                        level: level as! Int,
                                        dailyPoints: dailyPoints as! Int,
                                        weeklyPoints: weeklyPoints as! Int,
                                        totalPoints: totalPoints as! Int,
                                        imageURL: imageURL as! String)
                
                newDailyPlayers.append(playerItem)
                
                self.dailyTopPlayers = newDailyPlayers
                self.dailyTopPlayers.sort(by: {$0.dailyPoints > $1.dailyPoints})
                self.leaderboardTableView.reloadData()
            }
        })
    }
    
    func getWeeklyTopPlayers() {
        usersRef.queryOrdered(byChild: "weekly_points").queryLimited(toLast: 10).observe(.value, with: { snapshot in
            var newWeeklyPlayers: [Player] = []
            
            let playerDict = snapshot.value as? [String : AnyObject] ?? [:]
            for player in playerDict {
                let attributes = player.value
                let username = attributes["username"]
                let level = attributes["level"]
                let dailyPoints = attributes["daily_points"]
                let weeklyPoints = attributes["weekly_points"]
                let totalPoints = attributes["total_points"]
                let imageURL = attributes["imageURL"]
                
                let playerItem = Player(username: username as! String,
                                        level: level as! Int,
                                        dailyPoints: dailyPoints as! Int,
                                        weeklyPoints: weeklyPoints as! Int,
                                        totalPoints: totalPoints as! Int,
                                        imageURL: imageURL as! String)
                
                newWeeklyPlayers.append(playerItem)
                
                self.weeklyTopPlayers = newWeeklyPlayers
                self.weeklyTopPlayers.sort(by: {$0.weeklyPoints > $1.weeklyPoints})
                self.leaderboardTableView.reloadData()
            }
        })
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var returnValue = 0
        
        switch leaderboardSegmentedControl.selectedSegmentIndex {
        case 0:
            returnValue = dailyTopPlayers.count
            break
        case 1:
            returnValue = weeklyTopPlayers.count
            break
        default:
            break
        }
        return returnValue
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = leaderboardTableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath) as! LeaderboardTableViewCell

        // Configure the cells
        let dailyPlayerString = dailyTopPlayers[indexPath.row]
        let weeklyPlayerString = weeklyTopPlayers[indexPath.row]

        switch leaderboardSegmentedControl.selectedSegmentIndex {
        case 0:
            cell.rankLabel!.text = "\(indexPath.row + 1)"
            cell.playerNameLabel!.text = "\(dailyPlayerString.username)"
            cell.pointsLabel!.text = "\(dailyPlayerString.dailyPoints)"
            if dailyPlayerString.imageURL != "default_profile" {
                let url = URL(string: "\(dailyPlayerString.imageURL)")
                cell.profileImage!.kf.setImage(with: url)
                cell.profileImage!.layer.borderWidth = 1
                cell.profileImage!.layer.masksToBounds = false
                cell.profileImage!.layer.borderColor = UIColor.black.cgColor
                cell.profileImage!.layer.cornerRadius = cell.profileImage!.frame.height/2
                cell.profileImage!.clipsToBounds = true
            } else {
                cell.profileImage!.image = UIImage(named: "\(dailyPlayerString.imageURL)")
                cell.profileImage!.layer.borderWidth = 0
            }
            break
        case 1:
            cell.rankLabel!.text = "\(indexPath.row + 1)"
            cell.playerNameLabel!.text = "\(weeklyPlayerString.username)"
            cell.pointsLabel!.text = "\(weeklyPlayerString.weeklyPoints)"
            if weeklyPlayerString.imageURL != "default_profile" {
                let url = URL(string: "\(weeklyPlayerString.imageURL)")
                cell.profileImage!.kf.setImage(with: url)
                cell.profileImage!.layer.borderWidth = 1
                cell.profileImage!.layer.masksToBounds = false
                cell.profileImage!.layer.borderColor = UIColor.black.cgColor
                cell.profileImage!.layer.cornerRadius = cell.profileImage!.frame.height/2
                cell.profileImage!.clipsToBounds = true
            } else {
                cell.profileImage!.image = UIImage(named: "\(weeklyPlayerString.imageURL)")
                cell.profileImage!.layer.borderWidth = 0
            }
            break
        default:
            break
        }
        cell.playerNameLabel!.adjustsFontSizeToFitWidth = true
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "listToDetail" {
            
            let profileViewController = segue.destination as! ProfileViewController
            let index = leaderboardTableView.indexPathForSelectedRow!.row
            
            if leaderboardSegmentedControl.selectedSegmentIndex == 0 {
                profileViewController.player = dailyTopPlayers[index]
            } else {
                profileViewController.player = weeklyTopPlayers[index]
            }
        }
    }
}
