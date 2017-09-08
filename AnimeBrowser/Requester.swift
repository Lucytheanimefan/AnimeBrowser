//
//  Requester.swift
//  AnimeBrowser
//
//  Created by Lucy Zhang on 9/8/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import Cocoa
import os.log

class Requester: NSObject {
    static let ANN:String = "https://www.animenewsnetwork.com"
    static let reportsEndpoint:String = "/encyclopedia/reports.xml?id="
    static let recentlyAddedAnimeID:String = "148"
    static let recentlyAddedMangaID:String = "149"
    static let recentlyAddedCompaniesID = "151"
    static let ratingsID = "172"
    
    // XML Parser Delegate
    var xmlElementName:String!
    var elementValue: String?
    var xmlChunk:[String:Any]! = [String:Any]()
    var xmlChunks:[[String:Any]]! = [[String:Any]]()
    var success = false
    
    
    var completion:(([[String:Any]])->Void)!
    
    // type is GET or POST
    func makeRequest(endpoint:String, parameters:[String:Any]?, type:String, completion:@escaping ((_ data:[[String:Any]])->Void)){
        self.completion = completion
        var request = URLRequest(url: URL(string: Requester.ANN + Requester.reportsEndpoint + endpoint)!)
        request.httpMethod = type
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            if (err != nil){
                print("Error with request :(")
                print(err!.localizedDescription)
            }
            else{
                print("Parsing")
                let parser = XMLParser(data: data!)
                parser.delegate = self
                parser.parse()
            }
            }.resume()
    }
    
}

extension Requester:XMLParserDelegate{
    
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        xmlElementName = elementName
        if let url = attributeDict["href"]{
            xmlChunk["href"] = url
        }
        
    }
    
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        //os_log("%@: %@ : %@", self.className, xmlElementName, string)

        xmlChunk[xmlElementName] = string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if (elementName == "item"){
            print("append to chunks")
            // append the chunk
            xmlChunks.append(xmlChunk)
        }
        // Finished 1 chunk of data, time to do something with it
        if (elementName == "report"){
            print("Ready to do completion with report")
            //os_log("%@: CHUNK: %@", self.className, xmlChunk)
            self.completion(xmlChunks)
            xmlChunks = [[String:Any]]()
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("parseErrorOccurred: \(parseError)")
    }
}
