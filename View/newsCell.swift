//
//  newsCell.swift
//  StocketMarket
//
//  Created by labuser on 11/14/18.
//

import Foundation

import UIKit
import WebKit

class newsCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    
    
    @IBOutlet weak var date: UILabel!
    
    
    @IBOutlet weak var descript: UILabel!
    
    var link:String!
    
    
    var item: RSSItem!{
        
        didSet{
            title.text = item.title
            descript.text = item.description
            date.text = item.pubDate
        }
    }


    
    
}

