//
//  ViewController.swift
//  438 Final App
//
//  Created by BrianLin on 11/11/18.
//  Copyright © 2018 BrianLin. All rights reserved.
//

import UIKit
import RadarChartView
import Firebase
import FirebaseDatabase

protocol PlayerDetailViewControllerDelegate {
    func buyPlayer(id: Int, name: String)
    func sellPlayer(id: Int)
}

class PlayerDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var unitPriceLabel: UILabel!
    var gradientLayer: CAGradientLayer!
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height )
        
        gradientLayer.colors = [UIColor(red: 0.149, green: 0.2353, blue: 0.4431, alpha: 1.0).cgColor, UIColor(red: 0.0745, green: 0.1176, blue: 0.2235, alpha: 1.0).cgColor]
        gradientLayer.locations = [0.25, 0.75]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @IBOutlet weak var playerImage: UIImageView!
    var imageSrc: String?
    var playerName: String?
    @IBOutlet weak var radarChart: RadarChartView!
    @IBOutlet weak var statsView: UITableView!
    var gamelogs: [MSFData.PlayerGamelog]?
    var playerData: [MSFData.Player] = []
    var playerId: Int? = 9386
    var ref: DatabaseReference!
    var ref1:DatabaseReference!
    
    
    @IBOutlet weak var sharesOnHand: UILabel!
    var delegate: PlayerDetailViewControllerDelegate?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? BuyViewController {
            destinationViewController.delegate = delegate
            destinationViewController.transactedPlayerId = playerId
            destinationViewController.transactedPlayerName = navigationItem.title
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let gamelogs = gamelogs {
            return gamelogs.count
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! StatsViewCell
        
        cell.awayTeamLabel.text = gamelogs?[indexPath.row].game.awayTeamAbbreviation
        cell.homeTeamLabel.text = gamelogs?[indexPath.row].game.homeTeamAbbreviation
        cell.dateLabel.text = gamelogs?[indexPath.row].game.startTime
        cell.pointsLabel.text = String(gamelogs?[indexPath.row].stats.offense.points ?? -1)
        cell.assistsLabel.text = String(gamelogs?[indexPath.row].stats.offense.assists ?? -1)
        cell.reboundsLabel.text = String(gamelogs?[indexPath.row].stats.rebounds.rebounds ?? -1)
        cell.fieldGoalLabel.text = String(format: "%.1f", gamelogs?[indexPath.row].stats.fieldGoals.fieldGoalPercentage ?? -1)
        cell.fieldGoalLabel.sizeToFit()
        return cell
    }
    
    override func viewDidLoad() {
        
        createGradientLayer()
        
        
        
        super.viewDidLoad()
        statsView.dataSource = self
        statsView.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        let nib = UINib(nibName: "StatsViewCell", bundle: nil)
        
        statsView.register(nib, forCellReuseIdentifier: "LabelCell")
        
        guard let playerId = playerId else {
            return
        }
        DataModel.getGamelogForPlayer(playerId: playerId) {
            gamelogs in
           self.gamelogs = gamelogs
            self.statsView.reloadData()
        }
        
        ref = Database.database().reference().child("PlayerPrice")
        ref.observe(.value) { (snapshot) in
            let id = String(playerId)
            let value = snapshot.value as? NSDictionary
            let price = value?[id] as? Double ?? 0.0
            self.unitPriceLabel.text = String(price)
            print(price)
            
            
        }
        
       
        
        print(playerId)
//
        let currentUserId = Auth.auth().currentUser?.uid
        ref1 = Database.database().reference().child("users").child(currentUserId!).child("purchasedPlayers").child(String(playerId))
        ref1.observe(.value) { (snapshot) in
                       let value = snapshot.value as? NSDictionary
                       let sharesOwned = value?["Shares Owned"] as? Int ?? 0
                       print(sharesOwned)
                       self.sharesOnHand.text = String(sharesOwned)
            
            
        }
        
        
        
        
        
        if let imageURL = URL(string:imageSrc ?? ""){
            playerImage.load(url: imageURL)
        }
        
        if let nameYa = playerName {
             self.navigationItem.title = nameYa
        }
        
        //put this in its own function to get the data values
        var dataSet = ChartDataSet()
        dataSet.entries = [ChartDataEntry(value: 83),
                           ChartDataEntry(value: 70),
                           ChartDataEntry(value: 90),
                           ChartDataEntry(value: 80),
                           ChartDataEntry(value: 90),
        ]
        radarChart.dataSets = [dataSet]
        radarChart.titles = ["Defense", "Offense", "Rebounding", "Consistency", "Potential"]
        radarChart.webTitles = ["20", "40", "60", "80", "100"]
        radarChart.frame = CGRect(x: 0, y: 0, width: 200, height: 160)
        //        radarChart.backgroundColor =  UIColor(red: 0.149, green: 0.2353, blue: 0.4431, alpha: 1.0)
        radarChart.backgroundColor = UIColor.clear
        self.view.addSubview(radarChart)
        
       
        
    }
//
//    func getUsersPlayerShares(){
//        let currentUserId = Auth.auth().currentUser?.uid
//        guard let id = transactedPlayerId else {
//            return
//        }
//        print(currentUserId)
//        ref1 = Database.database().reference().child("users").child(currentUserId!).child("purchasedPlayers").child(String(id))
//        ref1.observe(.value) { (snapshot) in
//            let value = snapshot.value as? NSDictionary
//            let sharesOwned = value?["Shares Owned"] as? Int ?? 0
//            print(sharesOwned)
//            self.sharesOwned.text = String(sharesOwned)
//
//        }
//
//
//
//    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

