//
//  PlayerCollectionData.swift
//  Scroll
//
//  Created by Amie Deng on 11/28/18.
//  Copyright © 2018 Amie Deng. All rights reserved.
//

import Foundation
import UIKit


class PlayerCollectionData {
    let id: Int!
    let name: String!
    let image: UIImage!
    init(id: Int, name: String) {
        self.id = id
        self.name = name
        if let image = UIImage(named: String(id)) {
            self.image = image
        }
        else {
            self.image = UIImage(named: "9218")
        }
    }
}

class PlayerCollectionManager {
    static var playerCollections: [PlayerCollectionData] = []
    class func addToPlayerCollections(id: Int, name: String) {
        let newCollection = PlayerCollectionData(id: id, name: name)
        playerCollections.append(newCollection)
    }
    class func deletePlayerCollection(forId id: Int) {
        for i in 0..<playerCollections.count {
            if playerCollections[i].id == id {
                playerCollections.remove(at: i)
                break
            }
        }
    }
}
