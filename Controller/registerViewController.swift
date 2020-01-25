//
//  registerViewController.swift
//  StocketMarket
//
//  Created by Gary  on 12/1/18.
//

import UIKit
import Firebase
import FirebaseDatabase

class registerViewController: UIViewController {
    var gradientLayer: CAGradientLayer!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var LastNameText: UITextField!
    
    @IBOutlet weak var phoneNumberText: UITextField!
    @IBOutlet weak var ageText: UITextField!
    
    var ref: DatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference().child("users")
       
        // Do any additional setup after loading the view.
        createGradientLayer()
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
    
    func addusers(){
        //let key = ref.childByAutoId().key
        let userID = Auth.auth().currentUser?.uid
        let user = ["id":userID!, "firstName":firstNameText.text! as String, "lastName":LastNameText.text! as String, "phoneNumber": phoneNumberText.text! as String, "age": ageText.text! as String, "balance": 50000 as Double] as [String : Any]
        ref.child(userID!).setValue(user)
        
    }
    
    func createUser(email:String, password: String){
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if error == nil{
                print("user created")
                self.signInUser(email: email, password: password)
                self.performSegue(withIdentifier: "toApp", sender: self)
                self.addusers()
            } else if error?._code == AuthErrorCode.emailAlreadyInUse.rawValue{
                self.alreadyInUse()
            }else{
                print("there is an error")
            }
        }
        
    }
    
    func signInUser(email: String, password: String){
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error == nil{
                print("user signed in")
                
            }else{
                print("there is an error")
            }
        }
        
    }
    
    
    @IBAction func confirmButton(_ sender: Any) {
        createUser(email: emailTextField.text!, password: passwordTextField.text!)
        
    }
    
    
    @IBAction func backToHome(_ sender: Any) {
         //performSegue(withIdentifier: "toHome", sender: self)
         self.dismiss(animated: true, completion: nil)
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
