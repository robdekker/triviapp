//
//  LeaderboardTableViewController.swift
//  Triviapp
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
        self.tableView.reloadData()
    }
    
    // Properties
    var dailyTopPlayers = [Player]()
    var weeklyTopPlayers = [Player]()
    
    // Constants
    let usersRef = Database.database().reference(withPath: "users")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usersRef.keepSynced(true)
        usersRef.queryOrdered(byChild: "weekly_points").queryLimited(toLast: 10).observe(.value, with: { snapshot in
            var newWeeklyPlayers: [Player] = []
            
            let playerDict = snapshot.value as? [String : AnyObject] ?? [:]
            for player in playerDict {
                let attributes = player.value
                let username = attributes["username"]
                let level = attributes["level"]
                let dailyPoints = attributes["daily_points"]
                let weeklyPoints = attributes["weekly_points"]
                let timesWon = attributes["times_won"]
                
                let playerItem = Player(username: username as! String,
                                        level: level as! Int,
                                        dailyPoints: dailyPoints as! Int,
                                        weeklyPoints: weeklyPoints as! Int,
                                        timesWon: timesWon as! Int)
                
                newWeeklyPlayers.append(playerItem)
                
                self.weeklyTopPlayers = newWeeklyPlayers
                self.weeklyTopPlayers.sort(by: {$0.weeklyPoints > $1.weeklyPoints})
                self.tableView.reloadData()
            }
        })
        
        usersRef.queryOrdered(byChild: "daily_points").queryLimited(toLast: 10).observe(.value, with: { snapshot in
            var newDailyPlayers: [Player] = []
            
            let playerDict = snapshot.value as? [String : AnyObject] ?? [:]
            for player in playerDict {
                let attributes = player.value
                let username = attributes["username"]
                let level = attributes["level"]
                let dailyPoints = attributes["daily_points"]
                let weeklyPoints = attributes["weekly_points"]
                let timesWon = attributes["times_won"]
                
                let playerItem = Player(username: username as! String,
                                        level: level as! Int,
                                        dailyPoints: dailyPoints as! Int,
                                        weeklyPoints: weeklyPoints as! Int,
                                        timesWon: timesWon as! Int)
                
                newDailyPlayers.append(playerItem)
    
                self.dailyTopPlayers = newDailyPlayers
                self.dailyTopPlayers.sort(by: {$0.dailyPoints > $1.dailyPoints})
                self.tableView.reloadData()
            }
        })
        
        self.tableView.rowHeight = 44;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath) as! LeaderboardTableViewCell

        // Configure the cells
        let dailyPlayerString = dailyTopPlayers[indexPath.row]
        let weeklyPlayerString = weeklyTopPlayers[indexPath.row]

        switch leaderboardSegmentedControl.selectedSegmentIndex {
        case 0:
            cell.rankLabel!.text = "\(indexPath.row + 1)"
            cell.playerNameLabel!.text = "\(dailyPlayerString.username)"
            cell.pointsLabel!.text = "\(dailyPlayerString.dailyPoints)"
            break
        case 1:
            cell.rankLabel!.text = "\(indexPath.row + 1)"
            cell.playerNameLabel!.text = "\(weeklyPlayerString.username)"
            cell.pointsLabel!.text = "\(weeklyPlayerString.weeklyPoints)"
            break
        default:
            break
        }

        cell.playerNameLabel!.adjustsFontSizeToFitWidth = true

        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "listToDetail" {
            
            let playerDetailViewController = segue.destination as! PlayerDetailViewController
            let index = tableView.indexPathForSelectedRow!.row
            
            if leaderboardSegmentedControl.selectedSegmentIndex == 0 {
                playerDetailViewController.player = dailyTopPlayers[index]
            } else {
                playerDetailViewController.player = weeklyTopPlayers[index]
            }
        }
    }

}

