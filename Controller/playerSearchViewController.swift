//
//  playerSearchViewController.swift
//  StocketMarket
//
//  Created by labuser on 11/18/18.
//

import UIKit
import Firebase
import FirebaseDatabase

class playerSearchViewController: UIViewController, UIPickerViewDelegate,UIPickerViewDataSource {
    
    var gradientLayer: CAGradientLayer!
    var ref: DatabaseReference!
    var delegateBaton: PlayerDetailViewControllerDelegate?
    
    @IBOutlet weak var dismissButton: UIButton!
    
    @IBAction func disButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
        
    }
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var ageLabel: UILabel!
    
    @IBOutlet weak var heightLabel: UILabel!
    
    @IBOutlet weak var weightLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    var imageSource: String?
    
    var dataModel = DataModel()
    
    var selectedPlayerId: Int?
    var selectedPlayerName: String?
    var selectedPlayerImageSource: String?
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        priceLabel.text = "$5.2"
        ageLabel.text = "22"
        heightLabel.text = "6'2\""
        weightLabel.text =  "190lbs"
        imageView.image = #imageLiteral(resourceName: "jaylen")
        
        
        dataModel.updateTeams() {
            self.pickerView.reloadComponent(0)
            self.dataModel.updatePlayers() {
                if !self.dataModel.teams.isEmpty {
                    self.dataModel.selectedTeamId = self.dataModel.teams[0].id
                }
                self.pickerView.reloadComponent(1)
            }
        }
        createGradientLayer()
    }
    
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height )
        
        gradientLayer.colors = [UIColor(red: 0.149, green: 0.2353, blue: 0.4431, alpha: 1.0).cgColor, UIColor(red: 0.0745, green: 0.1176, blue: 0.2235, alpha: 1.0).cgColor]
        gradientLayer.locations = [0.25, 0.75]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // Picker View DataSource
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return dataModel.teams.count
            
        } else {
            return dataModel.playersFromSelectedTeam.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return (dataModel.teams[row].abbreviation) + " " +  (dataModel.teams[row].name ?? "")
        } else {
            return (dataModel.playersFromSelectedTeam[row].firstName + " " +  dataModel.playersFromSelectedTeam[row].lastName)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            dataModel.selectedTeamId = dataModel.teams[row].id
            pickerView.reloadComponent(1)
        } else {
            imageSource = dataModel.playersFromSelectedTeam[row].officialImageSrc
           
            if let imageURL = URL(string: imageSource ?? "") {
                imageView.load(url: imageURL)
            }
            
            //uploading other data
             
            
            if let age = dataModel.playersFromSelectedTeam[row].age {
                ageLabel.text = "\(age)"
               
            }
            
            if let height = dataModel.playersFromSelectedTeam[row].height{
                heightLabel.text = "\(height)"
            }
            
            if let weight = dataModel.playersFromSelectedTeam[row].weight{
                weightLabel.text = "\(weight) lbs"
            }
            
            
           
            selectedPlayerId = dataModel.playersFromSelectedTeam[row].id
            selectedPlayerName = dataModel.playersFromSelectedTeam[row].firstName + " " + dataModel.playersFromSelectedTeam[row].lastName
            selectedPlayerImageSource = dataModel.playersFromSelectedTeam[row].officialImageSrc
            
            ref = Database.database().reference().child("PlayerPrice")
            ref.observe(.value) { (snapshot) in
                guard let id = self.selectedPlayerId else {
                    return
                }
                let value = snapshot.value as? NSDictionary
                let price = value?[String(id)] as? Double ?? 0.0
                self.priceLabel.text = "$" + String(format:"%.2f",price)
                print(price)
                
                
            }
            
            
            
        }
        
    }
    @IBAction func viewMore(_ sender: Any) {
        //send data over to the detailedViewController
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "toPlayerDetail" {
                guard let playerDetailViewController = segue.destination as? PlayerDetailViewController else {return}
                playerDetailViewController.playerId = selectedPlayerId
                playerDetailViewController.title = selectedPlayerName
                playerDetailViewController.imageSrc = selectedPlayerImageSource
                playerDetailViewController.delegate = delegateBaton
            }
        }
    }
    

    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var string:String!
        if component == 0 {
            string = dataModel.teams[row].abbreviation + " " +  dataModel.teams[row].name
        } else {
           string = dataModel.playersFromSelectedTeam[row].firstName + " " +  dataModel.playersFromSelectedTeam[row].lastName
        }
        
        return NSAttributedString(string: string, attributes: [NSAttributedStringKey.foregroundColor:UIColor.white,
                                                               NSAttributedStringKey.font:UIFont(name: "Gill Sans", size: 18)!])
    }
    
//    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//        let label = view as? UILabel ?? UILabel()
//        label.font = .systemFont(ofSize: 18)
//        label.textColor = .white
//        label.textAlignment = .center
//        label.text = text(for: row, for: component)
//        return label
//    }
    
   
    
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
