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
    let ANN:String = "https://www.animenewsnetwork.com/"
    let reportsEndpoint:String = "encyclopedia/reports.xml?id="
    let recentlyAddedAnimeID:String = "148"
    let recentlyAddedMangaID:String = "149"
    let recentlyAddedCompaniesID = "151"
    let ratingsID = "172"
    
    // XML Parser Delegate
    var xmlElementName:String!
    var elementValue: String?
    var xmlChunk:[String:Any]! = [String:Any]()
    var success = false
    
    
    var completion:(([String:Any])->Void)!
    
    // type is GET or POST
    func makeRequest(endpoint:String, parameters:[String:Any]?, type:String, completion:@escaping ((_ data:[String:Any])->Void)){
        self.completion = completion
        var request = URLRequest(url: URL(string: ANN + reportsEndpoint + endpoint)!)
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
        
    }
    
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        //os_log("%@: %@ : %@", self.className, xmlElementName, string)

        xmlChunk[xmlElementName] = string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        // Finished 1 chunk of data, time to do something with it
        if (elementName == "item"){
            os_log("%@: CHUNK: %@", self.className, xmlChunk)
            xmlChunk = [String:Any]()
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("parseErrorOccurred: \(parseError)")
    }
}
