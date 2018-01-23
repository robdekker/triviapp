//
//  LeaderboardTableViewCell.swift
//  Triviapp
//
//  Created by Rob Dekker on 20-01-18.
//  Copyright © 2018 Rob Dekker. All rights reserved.
//

import UIKit

class LeaderboardTableViewCell: UITableViewCell {
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
