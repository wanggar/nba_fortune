//
//  ViewController.swift
//  StocketMarket
//
//  Created by labuser on 11/14/18.
//

import UIKit
import WebKit


var nbaImage:UIImage!
var nbaPrice: String!
var nbaId: Int!
var nbaImgSrc:String!
var nbaName: String!


class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource, PlayerDetailViewControllerDelegate{
    var gradientLayer: CAGradientLayer!
    
    
    @IBOutlet weak var newsTableView: UITableView!
    
    var database = DataModel()
    
    @IBOutlet weak var playerCollectionView: UICollectionView!

    
    
    @IBAction func searchButton(_ sender: Any) {
       // playerSearcher.isHidden = false
        
    }
    
    var playerImages:[UIImage] = [UIImage(named: "9157")!,UIImage(named: "9158")!,UIImage(named: "9386")!] //placeholder data
    var playerPrice:[String] = ["$105.2","$92.56","$119.92"]//placeholder data
    var playerList: [MSFData.Players] = []
    var player1:MSFData.Player!
    var ids:[Int] = [9157,9158,9386]
    var src: [String] = [ "https://ak-static.cms.nba.com/wp-content/uploads/headshots/nba/latest/260x190/202681.png"
,"https://ak-static.cms.nba.com/wp-content/uploads/headshots/nba/latest/260x190/2544.png","https://ak-static.cms.nba.com/wp-content/uploads/headshots/nba/latest/260x190/201142.png"]
    var names:[String] = ["Kyrie Irving","Lebron James","Kevin Durant"]
    

    
    private var rssItems: [RSSItem]?
    
    var nbalink:String!
    
  
   
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = false
     
        view.backgroundColor = UIColor.init(red: 37/255, green: 59/255, blue: 117/255, alpha: 1.0)
        
        playerCollectionView.delegate = self
        playerCollectionView.dataSource = self
        playerCollectionView.reloadData()
        
        
        newsTableView.estimatedRowHeight = 155.0;
        newsTableView.rowHeight = UITableViewAutomaticDimension
        newsTableView.dataSource = self
        newsTableView.delegate = self
        
        fetchData()
        updatePlayerCollections()
        
        createGradientLayer()
    }
    
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height )
        
        gradientLayer.colors = [UIColor(red: 0.149, green: 0.2353, blue: 0.4431, alpha: 1.0).cgColor, UIColor(red: 0.0745, green: 0.1176, blue: 0.2235, alpha: 1.0).cgColor]
        gradientLayer.locations = [0.25, 0.75]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func updatePlayerCollections() {
        if let navivc = tabBarController?.viewControllers?[1] as? UINavigationController {
            if let vc = navivc.viewControllers.first as? PlayerCollectionViewController {
                //update player collections according to the counters
                // *** FOR LOOP ***
                //let id = ****
                //let player = database.getPlayer(with: id)
                //let name = ...
               
                for (id, value) in Counter.values{
                    if value.1 <= 0 {
                        continue
                    }
                    let name = value.0
                
                    vc.addPlayerCollections(id: Int(id)!, name: name)
                    
                }
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func fetchData(){
        let feedParser = FeedParser()
        
        
        feedParser.parseFeed(url: "https://www.nba.com/rss/nba_rss.xml") { (rssItems) in
            self.rssItems = rssItems
            OperationQueue.main.addOperation {
                self.newsTableView.reloadSections(IndexSet(integer:0), with: .left)
                
            }
        }
        
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mycell", for: indexPath) as! theCell
        cell.playerImage.image = playerImages[indexPath.row]
        cell.playerPrice.text = playerPrice[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
         nbaImage = playerImages[indexPath.row]
         nbaPrice = playerPrice[indexPath.row]
         nbaId = ids[indexPath.row]
         nbaImgSrc = src[indexPath.row]
         nbaName = names[indexPath.row]
        
         print(nbaImage)
         print(nbaPrice)
         performSegue(withIdentifier: "toPlayerDetail", sender: nil)
        
        
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard let rssItems = rssItems else {
            return 0
        }
        return rssItems.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let rssArticle = self.rssItems![indexPath.row]
         let newsPost = newsDetailedViewController()
         nbalink = rssArticle.link
         performSegue(withIdentifier: "toNBANews", sender: self)
         newsPost.feedLink = nbalink
         newsPost.reloadInputViews()
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is newsDetailedViewController{
            let vc = segue.destination as? newsDetailedViewController
            vc?.feedLink = nbalink // data transfer 
        }
        
        if let identifier = segue.identifier{
            if identifier == "toPlayerDetail" {
                guard let playerDetailViewController = segue.destination as? PlayerDetailViewController else{return}
               
                playerDetailViewController.playerId = nbaId
                playerDetailViewController.imageSrc = nbaImgSrc
                playerDetailViewController.playerName = nbaName
                if let player = database.getPlayer(with: nbaId) {
                    let name = player.firstName + " " + player.lastName
                    playerDetailViewController.navigationItem.title = name
                }
                
                playerDetailViewController.delegate = self

                //playerDetailViewController.delegate = self
                
            }
            if identifier == "toSearchPage" {
                guard let playerSearchViewController = segue.destination as? playerSearchViewController else{return}
                
                playerSearchViewController.delegateBaton = self
                
    
            }
            if identifier == "toNBANews" {
                guard let newsDetailedViewController = segue.destination as? newsDetailedViewController else{return}
                let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: newsDetailedViewController, action: #selector(newsDetailedViewController.goBack))
                newsDetailedViewController.navigationItem.backBarButtonItem = newBackButton
            }
        }
        
       
    } 
    

    
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! newsCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        if let item = rssItems?[indexPath.item]{
            cell.item = item
        }
        
        return cell
    }
    
    
    func buyPlayer(id: Int, name: String) {
//        if let vc = tabBarController?.viewControllers?[1] as? PlayerCollectionViewController {
//            vc.addPlayerCollections(id: id, name: name)
//        }
        if let navivc = tabBarController?.viewControllers?[1] as? UINavigationController{
            if let vc = navivc.viewControllers[0] as? PlayerCollectionViewController{
                vc.addPlayerCollections(id: id, name: name)
            }
        }
        
    }
    
    func sellPlayer(id: Int) {
        if let navivc = tabBarController?.viewControllers?[1] as? UINavigationController{
            if let vc = navivc.viewControllers[0] as? PlayerCollectionViewController{
                vc.deletePlayerCollection(forId: id)
            }
        }
    }

}

