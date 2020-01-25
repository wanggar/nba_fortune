//
//  XMLParser .swift
//  newsFeed
//
//  Created by labuser on 11/10/18.
//  Copyright © 2018 wustl. All rights reserved.
//

import Foundation

struct RSSItem{
    
    var title: String
    var description: String
    var pubDate: String
    var link: String
    
}


//download xml from a server
//parse xml to foundation objects
//call back to get the objects

class FeedParser: NSObject,XMLParserDelegate{
    private var rssItems:[RSSItem] = []
    private var currentElement = ""
    private var currenttitle: String = ""{
        didSet{
            currenttitle = currenttitle.trimmingCharacters(in:CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentDescription: String = ""{
        didSet{
            currentDescription = currentDescription.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentPubdate: String = ""{
        didSet{
            currentPubdate = currentPubdate.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentLink: String = ""{
        didSet{
            currentLink = currentLink.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        
    }
    private var parseCompletionHandler: (([RSSItem])-> Void)?
    
    
    func parseFeed(url:String, completionHandler:(([RSSItem]) -> Void)?){
        self.parseCompletionHandler = completionHandler
        let request = URLRequest(url:URL(string: url)!)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request){ (data, response, error) in
            guard let data = data else{
                if let error = error {
                    print(error.localizedDescription)
                }
                
                return
            }
            let parser = XMLParser(data:data)
            parser.delegate = self
            parser.parse()
        }
        
        task.resume()
    }
    
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if currentElement == "item" {
            currenttitle = ""
            currentDescription = ""
            currentPubdate = ""
            currentLink = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string:String ){
        switch currentElement{
        case "title": currenttitle += string
        case "description": currentDescription += string
        case  "pubDate": currentPubdate += string
        case "link": currentLink += string
        default: break
        }
    }
    
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let rssItem = RSSItem(title: currenttitle, description: currentDescription, pubDate: currentPubdate, link: currentLink)
            self.rssItems.append(rssItem)
        }
    }
    
    
    func parserDidEndDocument(_ parser: XMLParser) {
        parseCompletionHandler?(rssItems)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription)
        
    }
}
