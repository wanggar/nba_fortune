//
//  loginViewController.swift
//  StocketMarket
//
//  Created by Gary  on 12/1/18.
//

import UIKit
import Firebase

class Counter {
    static var values: [String: (String, Int)] = [:]
}

class loginViewController: UIViewController {
    var gradientLayer: CAGradientLayer!
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    var ref:DatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        emailText.attributedPlaceholder = NSAttributedString(string: " Email", attributes: [NSAttributedStringKey.foregroundColor:UIColor.white.withAlphaComponent(0.1)])
        passwordText.attributedPlaceholder = NSAttributedString(string: " Password", attributes: [NSAttributedStringKey.foregroundColor:UIColor.white.withAlphaComponent(0.1)])
        passwordText.isSecureTextEntry = true

        createGradientLayer()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height )
        
        gradientLayer.colors = [UIColor(red: 0.149, green: 0.2353, blue: 0.4431, alpha: 1.0).cgColor, UIColor(red: 0.0745, green: 0.1176, blue: 0.2235, alpha: 1.0).cgColor]
        gradientLayer.locations = [0.25, 0.75]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }

    
    
    //action
    @IBAction func login(_ sender: Any) {
        signInUser(email: emailText.text!, password: passwordText.text!)
    }
    
    
    @IBAction func register(_ sender: Any) {
        self.performSegue(withIdentifier: "toProfilePage", sender: self)
    }
    
    
    
    //sign in & sign up
    func createUser(email:String, password: String){
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if error == nil{
                print("user created")
                self.signInUser(email: email, password: password)
            } else if error?._code == AuthErrorCode.weakPassword.rawValue{
                self.passwordTooShortAlert()
            } else if error?._code == AuthErrorCode.emailAlreadyInUse.rawValue{
                self.alreadyInUse()
            }
            else{
                print("there is an error")
            }
        }
        
    }
    
    func signInUser(email: String, password: String){
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error == nil{
                print("user signed in")
                //assign to Counter.value
                self.readCounter()
            } else if error?._code == AuthErrorCode.userNotFound.rawValue {
                self.createUser(email: email, password: password)
            } else if error?._code == AuthErrorCode.wrongPassword.rawValue{
                self.wrongPasswordAlert()
            }
            else{
                print("there is an error")
            }
        }
        
    }
    
    func readCounter(){
        let currentUserId = Auth.auth().currentUser?.uid
        
        ref = Database.database().reference().child("users").child(currentUserId!).child("purchasedPlayers")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? NSDictionary else {return}
            for (id, player) in value {
                guard let player = player as? NSDictionary else {continue}
                guard let id = id as? String else {continue}
                let sharesOwned = player["Shares Owned"] as? Int ?? -1
                let 名字 = player["Name"] as? String ?? "Error"
                Counter.values[id] = (名字, sharesOwned)
                self.performSegue(withIdentifier: "toMain", sender: self)
            }
        }
        
        
        
    }
    
    //alert
    func wrongPasswordAlert(){
        
        let alert = UIAlertController(title: "Ouch!", message: "Please enter the correct password", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func passwordTooShortAlert(){
        let alert = UIAlertController(title: "Almost there!", message: "Your Password needs to be at least 7 characters", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func alreadyInUse(){
        let alert = UIAlertController(title: "Almost there!", message: "This e-mail has already been used", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
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
