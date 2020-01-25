//
//  DataModel.swift
//  StocketMarket
//
//  Created by labuser on 11/18/18.
//

import Foundation

struct MSFData {
    // Players API Data Structures
    struct Players: Decodable {
        let players: [PlayerItem]!
    }
    
    struct PlayerItem: Decodable {
        let player: Player!
        let teamAsOfDate: Team!
    }
    
    struct Player: Decodable {
        let id: Int!
        let jerseyNumber: Int!
        let firstName: String!
        let lastName: String!
        let age: Int!
        let birthDate: String!
        let height: String!
        let weight: Int!
        let officialImageSrc: String!
    }
    
    // Seasonal Standings Data Structures
    struct SeasonalStandings: Decodable {
        let teams: [TeamItem]!
    }
    
    struct TeamItem: Decodable {
        let team: Team!
    }
    
    struct Team: Decodable {
        let id: Int!
        let city: String?
        let name: String?
        let abbreviation: String!
    }
}

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
    
    
}

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
    private var playerItems: [MSFData.PlayerItem] = []
    var selectedTeamId: Int?
    var playersFromSelectedTeam: [MSFData.Player] {
        guard let id = selectedTeamId else {
            return []
        }
        var result: [MSFData.Player] = []
        for item in playerItems {
            guard let team = item.teamAsOfDate else {
                continue
            }
            if team.id == id,
                let player = item.player {
                result.append(player)
            }
        }
        return result
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
}

