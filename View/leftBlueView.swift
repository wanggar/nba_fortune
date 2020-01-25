//
//  leftBlueView.swift
//  FireBaseDemo
//
//  Created by Gary  on 11/22/18.
//  Copyright © 2018 Gary . All rights reserved.
//

import UIKit

class leftBlueView: UIView {

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        
        let upperOffSet = self.frame.width/2 - 20 //upper
        let lowerOffSet = self.frame.width/2 + 40 //lower
       
        UIColor.init(red: 37/255, green: 59/255, blue: 117/255, alpha: 1).set()
        
        let path1 = UIBezierPath()
        path1.move(to: CGPoint(x:0,y:0))
        path1.addLine(to: CGPoint(x: upperOffSet, y: 0))//upper
        path1.addLine(to:CGPoint(x:lowerOffSet, y:self.frame.height)) //lower
        path1.addLine(to: CGPoint(x: 0, y: self.frame.height))
        path1.close()
        
        path1.fill()
        
    
    }
    

}
