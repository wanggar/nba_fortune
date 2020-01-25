//
//  StatsViewCell.swift
//  
//
//  Created by BrianLin on 11/17/18.
//

import Foundation
import UIKit

class StatsViewCell: UITableViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()
    }
   
    
  
    @IBOutlet weak var awayTeamLabel: UILabel!
    @IBOutlet weak var homeTeamLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var assistsLabel: UILabel!
    @IBOutlet weak var reboundsLabel: UILabel!
    @IBOutlet weak var fieldGoalLabel: UILabel!
    @IBOutlet weak var winLossLabel: UILabel!
    
    
}
