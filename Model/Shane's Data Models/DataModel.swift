//
//  DataModel.swift
//  NBA Player
//
//  Created by Shane Whong on 11/8/18.
//  Copyright © 2018 Shane Wang. All rights reserved.
//

import Foundation

class Team {
    let id: Int!
    let city: String!
    let name: String!
    let abbreviation: String!
    var players: [MSFData.Player]
    init(team: MSFData.Team) {
        id = team.id
        city = team.city ?? ""
        name = team.name ?? ""
        abbreviation = team.abbreviation
        players = []
    }
}


class DataModel {
    private(set) var teams: [Team] = []
    var playerItems: [MSFData.PlayerItem] = []
    var selectedTeamId: Int?
    var playersFromSelectedTeam: [MSFData.Player] {
        guard let id = selectedTeamId else {
            return []
        }
        var result: [MSFData.Player] = []
        for item in playerItems {
            guard let team = item.teamAsOfDate else {continue}
            if item.player.currentRosterStatus != "ROSTER" {continue}
            if item.player.currentContractYear == nil {continue}
            if team.id == id,
                let player = item.player {
                result.append(player)
            }
        }
        return result
    }
    func getPlayer(with id: Int) -> MSFData.Player? {
        for item in playerItems {
            if item.player.id == id {
                return item.player
            }
        }
        return nil
    }
    func updateAll(completion: (() -> ())? = nil) {
        updateTeams()
        updatePlayers(completion: completion)
    }
    
    func updateTeams(completion: (() -> ())? = nil) {
        let urlString = "https://api.mysportsfeeds.com/v2.0/pull/nba/2018-2019-regular/standings.json"
        MySportsFeeds.sendRequest(urlString: urlString, type: .seasonalStandings) { responseData in
            guard let data = responseData as? MSFData.SeasonalStandings else {
                print("*** Response Data Error! ***")
                return
            }
            for teamItem in data.teams {
                let newTeam = Team(team: teamItem.team)
                self.teams.append(newTeam)
            }
            self.selectedTeamId = self.teams[0].id
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    func updatePlayers(completion: (() -> ())? = nil) {
        let urlString = "https://api.mysportsfeeds.com/v2.0/pull/nba/players.json"
        MySportsFeeds.sendRequest(urlString: urlString, type: .players) { responseData in
            guard let data = responseData as? MSFData.Players else {
                print("*** Response Data Error! ***")
                return
            }
            self.playerItems = data.players
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    class func getGamelogForPlayer(playerId: Int, completion: (([MSFData.PlayerGamelog]) -> ())? = nil) {
        let urlString = "https://api.mysportsfeeds.com/v2.0/pull/nba/2018-2019-regular/player_gamelogs.json?player=\(playerId)&limit=5&sort=game.starttime.D"
        MySportsFeeds.sendRequest(urlString: urlString, type: .seasonalPlayerGamelogs) {
            responseData in
            guard let data = responseData as? MSFData.SeasonalPlayerGamelogs else {
                print("*** Response Data Error! ***")
                return
            }
            DispatchQueue.main.async {
                completion?(data.gamelogs)
            }
        }
    }
    class func getGamelogsOfTeam(teamId: Int, completion:((Int, [MSFData.PlayerGamelog]) -> ())? = nil) {
        let urlString = "https://api.mysportsfeeds.com/v2.0/pull/nba/2018-2019-regular/player_gamelogs.json?team=\(teamId)&sort=game.starttime.D"
        MySportsFeeds.sendRequest(urlString: urlString, type: .seasonalPlayerGamelogs) {
            responseData in
            guard let data = responseData as? MSFData.SeasonalPlayerGamelogs else {
                print("*** Response Data Error! ***")
                return
            }
            DispatchQueue.main.async {
                completion?(teamId, data.gamelogs)
            }
        }
    }
}

//** Creating Player-Id Table
//func writeToTable(_ players: [MSFData.PlayerItem]) {
//    let fileName = "PlayerIdTable.txt"
//
//    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//        let fileURL = dir.appendingPathComponent(fileName)
//
//        do {
//            var text = ""
//            for playerItem in players {
//                guard let team = playerItem.teamAsOfDate?.abbreviation else {
//                    continue
//                }
//                let name = playerItem.player.firstName + " " + playerItem.player.lastName
//                let id = String(playerItem.player.id)
//
//                text += team + " | " + name + " | " + id
//                text += "\n"
//            }
//
//            try text.write(to: fileURL, atomically: true, encoding: .utf8)
//        }
//        catch {
//            print("some error")
//        }
//    }
//}
