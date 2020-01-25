//
//  JsonParser.swift
//  NBA Player
//
//  Created by Shane Whong on 11/15/18.
//  Copyright © 2018 Shane Wang. All rights reserved.
//

import Foundation

class JsonParser {
    //    class func forPlayers(dictionary: [String: Any]?) -> PlayersAPI.Players{
    //        let players = PlayersAPI.Players()
    //        return players
    //    }
    
    class func forPlayers(data: Data) -> MSFData.Players? {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(MSFData.Players.self, from: data)
        }
        catch {
            print("JSON decode error: \(error)")
            return nil
        }
    }
    
    class func forTeam(data: Data) -> MSFData.SeasonalStandings? {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(MSFData.SeasonalStandings.self, from: data)
        }
        catch {
            print("JSON decode error: \(error)")
            return nil
        }
    }
    
    class func forPlayerGamelogs(data: Data) -> MSFData.SeasonalPlayerGamelogs? {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(MSFData.SeasonalPlayerGamelogs.self, from: data)
        }
        catch {
            print("JSON decode error: \(error)")
            return nil
        }
    }
    
}
