//
//  MySportsFeed.swift
//  StocketMarket
//
//  Created by labuser on 11/18/18.
//

import Foundation


extension String {
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self, options: Data.Base64DecodingOptions(rawValue: 0)) else {
            return nil
        }
        return String(data: data as Data, encoding: String.Encoding.utf8)
    }
    func toBase64() -> String? {
        guard let data = self.data(using: String.Encoding.utf8) else {return nil}
        return data.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }
}

class MySportsFeeds {
    private static let apiKey = "d3ce0b9e-0e79-4d03-9f8f-911c70"
    private static let password = "MYSPORTSFEEDS"
    
    enum APICategory {
        case players
        case seasonalStandings
    }
    
    //    let urlString = "https://api.mysportsfeeds.com/v2.0/pull/nba/2018-2019-regular/standings.json"
    
    class func sendRequest(urlString: String, type: APICategory, completion: ((Any) -> ())? = nil) {
        guard let url = URL(string: urlString) else {
            print("*** URL error ***")
            return
        }
        let dataToEncode = String(apiKey + ":" + password)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields?["Authorization"] = "Basic " + dataToEncode.toBase64()!
        
        var dataTask: URLSessionDataTask?
        let session = URLSession.shared
        dataTask = session.dataTask(with: request) {
            data, httpresponse, error in
            
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            switch type {
            case .players:
                if let players = JsonParser.forPlayers(data: responseData) {
                    //print(players)
                    DispatchQueue.main.async {
                        completion?(players)
                        
                    }
                }
            case .seasonalStandings:
                if let teams = JsonParser.forTeam(data: responseData) {
                    //print(teams)
                    DispatchQueue.main.async {
                        completion?(teams)
                        
                    }
                }
            }
            
            //            print(String(data: responseData, encoding: .utf8)!)
        }
        dataTask?.resume()
    }
}
