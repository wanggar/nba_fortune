//
//  BuyAndSellViewController.swift
//  StocketMarket
//
//  Created by Gary  on 12/2/18.
//

import UIKit
import Firebase
import FirebaseDatabase




class BuyViewController: UIViewController {
    
    var gradientLayer: CAGradientLayer!
    var transactedPlayerId: Int? = 9086
    var transactedPlayerName: String?
 //   var pricePerShare: Double!
    var totalSum: Double!
    var ref: DatabaseReference!
    var ref1:DatabaseReference!
    var delegate: PlayerDetailViewControllerDelegate?
    var counter = 0
    var pricePerShare:Double!
    @IBOutlet weak var quantity: UITextField!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    var userId = Auth.auth().currentUser?.uid
    
    @IBOutlet weak var sharesAvailableLabel: UILabel!
    
    @IBAction func edittingDidChange(_ sender: Any) {
        
        print("texting")
        if let quan = Double(quantity.text!){
            let product = quan * pricePerShare
            totalLabel.text = String(format:"%.2f",product)
        } else {
            totalLabel.text = String(format:"%.2f",0.0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createGradientLayer()
        if let id = transactedPlayerId {
            renderPrice(playerID: id)
            peakStocksAvailable(playerId: id)
            
            ref = Database.database().reference().child("users").child(userId!).child("purchasedPlayers").child(String(id))
            
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let currentShareOwned = value?["Shares Owned"] as? Int ?? 0
            self.counter = currentShareOwned
            
            
            })
        
        }
        
        
    }
    
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height )
        
        gradientLayer.colors = [UIColor(red: 0.149, green: 0.2353, blue: 0.4431, alpha: 1.0).cgColor, UIColor(red: 0.0745, green: 0.1176, blue: 0.2235, alpha: 1.0).cgColor]
        gradientLayer.locations = [0.25, 0.75]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func renderPrice(playerID:Int){
        
        ref = Database.database().reference().child("PlayerPrice")
        ref.observe(.value) { (snapshot) in
            let id = String(playerID)
            let value = snapshot.value as? NSDictionary
            let price = value?[id] as? Double ?? 0.0
            self.priceLabel.text = String(format:"%.2f",price)
            self.pricePerShare = price
            print(self.pricePerShare)
            
        
        }
        
        
        
        
        
    }
    
    
    
    func peakStocksAvailable(playerId:Int){
        
        ref1 = Database.database().reference().child("OnMarketStock")
        ref1.observe(.value) { (snapshot) in
            let id = String(playerId)
            let value = snapshot.value as? NSDictionary
            let stockNumbers = value?[id] as? Int ?? -1
            print(stockNumbers)
            self.sharesAvailableLabel.text = String(stockNumbers)
        
        }
        
    }
    
    
    func buyCompleted() {
        let alert = UIAlertController(title: "Congratulations!", message: "Your have successfully bought your player stocks", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            self.navigationController?.popToRootViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func calculateTotal(_ sender: Any) {
        guard let id = transactedPlayerId, let name = transactedPlayerName else {
            return
        }
        
        if quantity.text! == "" {return}
        if let number = Int(quantity.text!), number == 0 {return}
    
        
        if counter == 0 {
            delegate?.buyPlayer(id: id, name: name)
        }
        
    //---------------------get the total Price-------------------
        ref = Database.database().reference().child("PlayerPrice")
       
        ref.observe(.value) { (snapshot) in
            guard let transactedPlayerId = self.transactedPlayerId else {return}
            guard let transactedPlayerName = self.transactedPlayerName else {return}
            let id = String(transactedPlayerId)
            let value = snapshot.value as? NSDictionary
            let price = value?[id] as? Double ?? 0.0
            self.priceLabel.text = String(format:"%.2f",price)
            self.pricePerShare = price
            print(self.pricePerShare)
            
           
            guard let number = Int(self.quantity.text!) else {return}
            
            self.counter = self.counter + number
            let total = Double(number) * self.pricePerShare
            print(total)
            self.totalLabel.text = String(format: "%.2f",total)
            
  //------------update current user balance------------------------
            let userId = Auth.auth().currentUser?.uid
           // self.ref = Database.database().reference().child("users").child("reOXzOC49BY45XF172zrNJL3ruI2")
            self.ref = Database.database().reference().child("users").child(userId!)
            let player = ["id":transactedPlayerId, "Shares Owned":self.counter, "Name": transactedPlayerName] as [String : Any]; self.ref.child("purchasedPlayers").child(String(transactedPlayerId)).setValue(player)
            
            self.ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let balance = value?["balance"] as? Double ?? 0.0
                print(total)
                let newbalance = Double(balance) - total
                print(newbalance)
                
 
                self.ref.updateChildValues(["balance" : newbalance])
                
                
  //-------------update available stock share -----------------------
                        self.ref = Database.database().reference().child("OnMarketStock")
                        self.ref.observeSingleEvent(of: .value, with: { (snapshot) in
                            let value = snapshot.value as? NSDictionary
                            //print(value)
                            let numberOfAvailableStocks = value?[String(transactedPlayerId)] as? Int ?? -1
                                let updatedNumberofStocks = numberOfAvailableStocks - number
                                print(updatedNumberofStocks)
                                self.ref.updateChildValues([String(transactedPlayerId) : updatedNumberofStocks])
                                self.buyCompleted()
                            })
                
                
            })
            
            

            
        }
        
        
    }
    
    
    
    
 
  

}
