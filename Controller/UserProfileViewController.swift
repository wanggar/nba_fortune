//
//  UserProfileViewController.swift
//  StocketMarket
//
//  Created by Gary  on 12/1/18.
//

import UIKit
import Firebase
import FirebaseDatabase

var userBalance:Int = 50000

class UserProfileViewController: UIViewController {
    
    
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var ageLabel: UILabel!
    
    @IBOutlet weak var phoneLabel: UILabel!
    
    @IBOutlet weak var balanceLabel: UILabel!
    
    var gradientLayer: CAGradientLayer!
    
    @IBOutlet weak var userProfileImage: UIImageView!
    
    @IBOutlet weak var userFirstNameLabel: UILabel!
    
    var bridge: Int!
    var uid = Auth.auth().currentUser?.uid
    var ref:DatabaseReference!
    
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height * 0.3 )
        
        gradientLayer.colors = [UIColor(red: 0.149, green: 0.2353, blue: 0.4431, alpha: 1.0).cgColor, UIColor(red: 0.0745, green: 0.1176, blue: 0.2235, alpha: 1.0).cgColor]
        gradientLayer.locations = [0.25, 0.75]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createGradientLayer()
        ref = Database.database().reference().child("users").child(uid!)
        sychronize()
        userProfileImage.layer.cornerRadius = userProfileImage.frame.height/2
        userProfileImage.image = #imageLiteral(resourceName: "user-30")
        userProfileImage.layer.borderWidth = 3
        userProfileImage.layer.masksToBounds = false
        userProfileImage.layer.borderColor = UIColor.white.cgColor
        userProfileImage.layer.cornerRadius = userProfileImage.frame.height/2
        userProfileImage.clipsToBounds = true
        // Do any additional setup after loading the view.
    }
    
    func sychronize(){
        //let uid = Auth.auth().currentUser?.uid
        //ref = Database.database().reference().child("users").child(uid!)
        ref.observe(.value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let firstName = value?["firstName"] as?String ?? ""
            let lastName = value? ["lastName"] as? String ?? ""
            let age = value?["age"] as? String ?? ""
            let phoneNum = value?["phoneNumber"] as? String ?? ""
            let balance = value?["balance"] as? Double ?? -1
            //            print(balance)
            //            print(firstName + lastName)
            //            print(age)
            //            print(phoneNum)
            self.nameLabel.text = firstName + " " + lastName
            self.ageLabel.text = age
            self.phoneLabel.text = phoneNum
            self.balanceLabel.text = String(format:"%.2f",balance)
            self.userFirstNameLabel.text = firstName
        }
        
        
    }
    
    
    
    @IBAction func Signout(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            print("Successfully signed out.")
            PlayerCollectionManager.playerCollections = []
            self.performSegue(withIdentifier: "signOut", sender: self)
        }catch{
            print("error")
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
