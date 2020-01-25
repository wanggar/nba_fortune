//
//  MSFData.swift
//  NBA Player
//
//  Created by Shane Whong on 11/15/18.
//  Copyright © 2018 Shane Wang. All rights reserved.
//

import Foundation

struct MSFData {
    // Players API Data Structures
    struct Players: Decodable {
        let players: [PlayerItem]!
    }
    
    struct PlayerItem: Decodable {
        let player: Player!
        let teamAsOfDate: Team?
    }
    
    struct Player: Decodable {
        let id: Int!
        let jerseyNumber: Int!
        let firstName: String!
        let lastName: String!
        let position: String!
        let age: Int!
        let birthDate: String!
        let height: String!
        let weight: Int!
        let officialImageSrc: String!
        let currentRosterStatus: String!
        let currentContractYear: ContractYear?
        
        struct ContractYear: Decodable {
            let seasonStartYear: Int!
            let baseSalary: Int!
        }
    }
}

extension MSFData {
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

extension MSFData {
    //Seasonal Player Gamelogs Data Structures
    struct SeasonalPlayerGamelogs: Decodable {
        let gamelogs: [PlayerGamelog]!
    }
    
    struct PlayerGamelog: Decodable {
        let game: Game!
        let player: Player!
        let team: Team!
        let stats: Stats!
    }
    struct Game: Decodable {
        let id: Int!
        let startTime: String!
        let awayTeamAbbreviation: String!
        let homeTeamAbbreviation: String!
    }
    
    //stats
    struct Stats: Decodable {
        let fieldGoals: FieldGoals!
        let freeThrows: FreeThrows!
        let rebounds: Rebounds!
        let offense: Offense!
        let defense: Defense!
        let miscellaneous: Miscellaneous!
    }
    
    struct FieldGoals: Decodable {
        let fieldGoal2PointMade: Int!
        let fieldGoal2PointMadePerGame: Double!
        let fieldGoal3PointMade: Int!
        let fieldGoal3PointMadePerGame: Double!
        let fieldGoalPercentage: Double!
        private enum CodingKeys: String, CodingKey {
            case fieldGoal2PointMade = "fg2ptMade"
            case fieldGoal2PointMadePerGame = "fg2ptPerGame"
            case fieldGoal3PointMade = "fg3ptMade"
            case fieldGoal3PointMadePerGame = "fg3ptPerGame"
            case fieldGoalPercentage = "fgPct"
        }
    }
    struct FreeThrows: Decodable {
        let freeThrowAttempt: Int!
        let freeThrowMade: Int!
        let freeThrowMadePerGame: Double!
        private enum CodingKeys: String, CodingKey {
            case freeThrowAttempt = "ftAtt"
            case freeThrowMade = "ftMade"
            case freeThrowMadePerGame = "ftMadePerGame"
        }
    }
    struct Rebounds: Decodable {
        let offenseRebounds: Int!
        let defenseRebounds: Int!
        let rebounds: Int!
        let reboundsPerGame: Double!
        private enum CodingKeys: String, CodingKey {
            case offenseRebounds = "offReb"
            case defenseRebounds = "defReb"
            case rebounds = "reb"
            case reboundsPerGame = "rebPerGame"
        }
    }
    struct Offense: Decodable {
        let assists: Int!
        let assistsPerGame: Double!
        let points: Int!
        let pointsPerGame: Double!
        private enum CodingKeys: String, CodingKey {
            case assists = "ast"
            case assistsPerGame = "astPerGame"
            case points = "pts"
            case pointsPerGame = "ptsPerGame"
        }
    }
    struct Defense: Decodable {
        let turnOvers: Int!
        let steals: Int!
        let blocks: Int!
        let turnOversPerGame: Double!
        let stealsPerGame: Double!
        let blocksPerGame: Double!
        private enum CodingKeys: String, CodingKey {
            case turnOvers = "tov"
            case steals = "stl"
            case blocks = "blk"
            case turnOversPerGame = "tovPerGame"
            case stealsPerGame = "stlPerGame"
            case blocksPerGame = "blkPerGame"
        }
    }
    struct Miscellaneous: Decodable {
        let fouls: Int!
        let foulsPerGame: Double!
        let technicalFouls: Int!
        private enum CodingKeys: String, CodingKey {
            case fouls
            case foulsPerGame
            case technicalFouls = "foulTech"
        }
    }
}

extension MSFData {
    struct SeasonalTeamGamelogs: Decodable {
        let gamelogs: [TeamGamelogs]!
    }
    
    struct TeamGamelogs: Decodable {
        let stats: TeamStats!
    }
    
    struct Standings: Decodable {
        let wins: Int!
    }
    
    struct TeamStats: Decodable {
        let standings: Standings!
    }
}
