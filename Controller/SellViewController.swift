//
//  SellViewController.swift
//  StocketMarket
//
//  Created by Gary  on 12/3/18.
//

import UIKit
import Firebase
import FirebaseDatabase

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}



class SellViewController: UIViewController {
    
    var transactedPlayerId:Int? = 9086
    var transactedPlayerName: String?
    var ref: DatabaseReference!
    var ref1:DatabaseReference!
    var userId = Auth.auth().currentUser?.uid
    var delegate: PlayerDetailViewControllerDelegate?
    
    @IBOutlet weak var sharesOwned: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantity: UITextField!
    @IBOutlet weak var totalPrice: UILabel!
    var pricePerShare: Double!
    var counter = 0
    var gradientLayer: CAGradientLayer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createGradientLayer()
        getUsersPlayerShares()
        if let id = transactedPlayerId {
            renderPrice(playerID: id)
            
            ref = Database.database().reference().child("users").child(userId!).child("purchasedPlayers").child(String(id))
            
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let currentShareOwned = value?["Shares Owned"] as? Int ?? 0
                self.counter = currentShareOwned
                
                
                print(self.counter)
                
                
            })
            
        }
        
        
      
        

        // Do any additional setup after loading the view.
    }
    
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height )
        
        gradientLayer.colors = [UIColor(red: 0.702, green: 0.1529, blue: 0.2118, alpha: 1.0).cgColor, UIColor(red: 0.5255, green: 0.0667, blue: 0.1176, alpha: 1.0).cgColor]
        gradientLayer.locations = [0.25, 0.75]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func edittingDidChange(_ sender: Any) {
        if let quan = Double(quantity.text!){
            let product = quan * pricePerShare
            totalPrice.text = String(format:"%.2f",product)
        }else {
            totalPrice.text = String(format:"%.2f",0.0)
        }
        
        
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
    
    
    func getUsersPlayerShares(){
        let currentUserId = Auth.auth().currentUser?.uid
        guard let id = transactedPlayerId else {
            return
        }
        print(currentUserId)
        ref1 = Database.database().reference().child("users").child(currentUserId!).child("purchasedPlayers").child(String(id))
        ref1.observe(.value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let sharesOwned = value?["Shares Owned"] as? Int ?? 0
            print(sharesOwned)
            self.sharesOwned.text = String(sharesOwned)
            
        }
        
        
        
    }
    
    
    func sellCompleted(){
        let alert = UIAlertController(title: "Congratulations!", message: "Your have successfully sold your player stocks", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    
    @IBAction func sell(_ sender: Any) {
        
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
            if self.counter < number {return}
            self.counter = self.counter - number
            if self.counter == 0 {
                self.delegate?.sellPlayer(id: transactedPlayerId)
            }
            let total = Double(number) * self.pricePerShare
            print(total)
            self.totalPrice.text = String(format: "%.2f",total)
            
            //------------update current user balance------------------------
            guard let userId = Auth.auth().currentUser?.uid else {return}
            self.ref = Database.database().reference().child("users").child(userId)
            let player = ["id":transactedPlayerId, "Shares Owned":self.counter, "Name": transactedPlayerName] as [String : Any]; self.ref.child("purchasedPlayers").child(String(transactedPlayerId)).setValue(player)
            
            self.ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let balance = value?["balance"] as? Double ?? 0.0
                print(total)
                let newbalance = Double(balance) + total
                print(newbalance)
                
                
                self.ref.updateChildValues(["balance" : newbalance])
                
                
                //-------------update available stock share -----------------------
                self.ref = Database.database().reference().child("OnMarketStock")
                self.ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    //print(value)
                    let numberOfAvailableStocks = value?[String(transactedPlayerId)] as? Int ?? -1
                    let updatedNumberofStocks = numberOfAvailableStocks + number
                    print(updatedNumberofStocks)
                    self.ref.updateChildValues([String(transactedPlayerId) : updatedNumberofStocks])
                    self.sellCompleted()
                })
                
                
            })
            
            
            
            
            
            
            
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
