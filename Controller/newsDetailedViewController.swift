//
//  newsDetailedViewController.swift
//  StocketMarket
//
//  Created by Gary  on 11/15/18.
//

import UIKit
import WebKit

class newsDetailedViewController: UIViewController,WKUIDelegate {

   
    
    var feedLink: String = ""
   
    @IBOutlet weak var webview: WKWebView!
    
    @objc
    func goBack() {
        tabBarController?.tabBar.isHidden = false
        _ = navigationController?.popViewController(animated: true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationItem.hidesBackButton = true
        
        //tabBarController?.tabBar.isHidden = true
        uploadNews()
        
    }
    
    func uploadNews(){
         let url = URL(string:feedLink)!
         let myURLRequest = URLRequest(url: url)
         print("world")
         print(webview)
         webview.load(myURLRequest)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
