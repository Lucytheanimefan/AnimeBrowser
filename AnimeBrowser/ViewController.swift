//
//  ViewController.swift
//  AnimeBrowser
//
//  Created by Lucy Zhang on 9/5/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import Cocoa
import WebKit
import Foundation

class ViewController: NSViewController {
    
    @IBOutlet weak var mainWebView: WKWebView!
    
    @IBOutlet weak var leftView: NSView!
    
    @IBOutlet weak var rightView: NSView!
    
    @IBOutlet weak var splitView: NSSplitView!
    
    @IBOutlet weak var tableView: NSTableView!
    
    @IBOutlet weak var totoroImageView: NSImageView!
    
    @IBOutlet var totoroTextView: NSTextView!
    
    @IBOutlet weak var sideBarSearchField: NSSearchField!
    
    // True if the sidebar has done a second level of searching for the selected row. Will not drill deeper than that...for now
    var madeSubSearch:Bool = false
    
    
    let requester = Requester()
    lazy var totoroImageData:Data? = {
        var imageData:Data!
        do{
            imageData = try Data(contentsOf: Bundle.main.url(forResource: "totoro_transparent", withExtension: "gif")!)
            return imageData
        }
        catch {
            print(error)
            return nil
        }
    }()
    
    lazy var totoroDanceImageData:Data? = {
        var imageData:Data!
        do{
            imageData = try Data(contentsOf: Bundle.main.url(forResource: "totoro_dance", withExtension: "gif")!)
            return imageData
        }
        catch {
            print(error)
            return nil
        }

    }()
    
    // This is used not only for anime, but for manga, companies and ratings too
    var sidebarData:[[String:Any]]! = [[String:Any]]()
    
    var sideBarResults:[URL]! = [URL(string:"https://www.animenewsnetwork.com")!, URL(string:"https://www.myanimelist.net")!]
    
    var count:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTotoroGIF()
        
        requester.makeRequest(endpoint: Requester.recentlyAddedAnimeID, parameters: nil, type: "GET") { (data) in
            print("Entered completion")
            self.sidebarData = data
            UserDefaults.standard.set(self.sidebarData, forKey: "sidebarData")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    
    override var representedObject: Any? {
        didSet {
 
        }
    }
    
    func setTotoroGIF(){
        totoroTextView.alignment = NSTextAlignment.center
        totoroTextView.string = "Watch anime"
        totoroImageView.animates = true
        let advTimeGif = NSImage(data: self.totoroImageData!)
        totoroImageView.image = advTimeGif
    }
    
    @IBAction func searchSideBar(_ sender: NSSearchField) {
        let text = sender.stringValue
        if (text.characters.count == 0){
            if let sidebarData = UserDefaults.standard.object(forKey: "sidebarData") as? [[String:Any]]{
                self.sidebarData = sidebarData
                print(self.sidebarData)
                self.tableView.reloadData()
                return
            }
        }
        let predicate = NSPredicate(format: "anime contains[c] %@ or manga contains[c] %@ or company contains[c] %@ or title contains[c] %@", text, text, text, text, text)

        let filteredEntries = ((self.sidebarData! as NSArray).filtered(using: predicate)) as! [[String:Any]]
        
        //print(filteredEntries)
        self.sidebarData = filteredEntries
        self.tableView.reloadData()
        //self.sidebarData = UserDefaults.standard.object(forKey: "sidebarData") as! [[String:Any]]
        
    }
    
}

extension ViewController:NSSplitViewDelegate{
    func splitView(_ splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
        return (subview.identifier == "leftView")
    }
    
    func splitView(_ splitView: NSSplitView, shouldAdjustSizeOfSubview view: NSView) -> Bool {
        return true
    }
}

extension ViewController: NSTableViewDataSource{
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.sidebarData.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 50
    }
    
}

extension ViewController:NSTableViewDelegate{
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return CustomRow()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let dict = self.sidebarData[row]
        
        if let view = tableView.make(withIdentifier: "webCell", owner: nil) as? CustomCell{
            
            // reddit
            if let data = dict["data"] as? [String:Any]{
                if let title = data["title"] as? String{
                    view.titleView.string = title
                }
                if let domain = data["domain"] as? String{
                    view.subtitle.stringValue = domain
                }
            } else {
                
                // ANN
                /*
                if let anime = dict["anime"] as? String{
                    //print(anime)
                    view.titleView.string = anime
                }
                else if let manga = dict["manga"] as? String{
                    view.titleView.string = manga
                }
                else if let company = dict["company"] as? String{
                    view.titleView.string = company
                }
                 */
                
                // MAL entries
                if let title = dict["title"] as? String{
                    view.titleView.string = title
                }
                
                // ANN ratings, MAL ratings
                if let avg = dict["bayesian_average"] as? String{
                    let index = avg.index(avg.startIndex, offsetBy: 3)
                    view.titleView.string = view.titleView.string! + ", " + avg.substring(to: index)
                }
                if let votes = dict["nb_votes"] as? String
                {
                    view.subtitle.stringValue = "Number of votes: " + votes
                }
                else if let date = dict["date_added"] as? String
                {
                    view.subtitle.stringValue = "Added: " + date
                }
                else if let userScore = dict["user_score"]
                {
                    view.subtitle.stringValue = "Score value: " + String(describing: userScore)
                }
            }
            return view
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let rowIndex = tableView.selectedRow
        let dict = self.sidebarData[rowIndex]
        var url:URL!
        if let urlString = dict["href"] as? String{
            url = URL(string:(Requester.ANN + urlString))!
        } else if let urlString = dict["url"] as? String{
            url = URL(string:urlString)
        }
        else if let data = dict["data"] as? [String:Any]{
            if let urlString = data["permalink"] as? String{
                url = URL(string: Requester.Reddit + urlString)
            }
        }
        if (url != nil){
            let req = URLRequest(url: url!)
            mainWebView.load(req)
            totoroTextView.string = "Let's go load!"
        }
        
        // Find entries relevant to searched
        // Reddit!
        if let query = dict["title"] as? String{
            let queryFormatted = removeSpecialCharsFromString(text: query).replacingOccurrences(of: " ", with: "+")
            
            requester.makeGeneralRequest(url: Requester.Reddit + Requester.RedditSearchEndpoint + queryFormatted, parameters: nil, type: "GET") { (results) in
                if let result = results as? [String:Any]{
                    if let data = result["data"] as? [String:Any]{
                        if let children = data["children"] as? [[String:Any]]{
                            if (children.count > 0){
                                self.sidebarData = children
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func removeSpecialCharsFromString(text: String) -> String {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-=_".characters)
        return String(text.characters.filter {okayChars.contains($0) })
    }
}

extension ViewController: WKNavigationDelegate{
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if let wc = NSApp.mainWindow?.windowController as? WindowController{
            wc.urlBackQueue.append(webView.url!)
            wc.urlField.stringValue = webView.url!.absoluteString
        }
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        let gif = NSImage(data: self.totoroDanceImageData!)
        totoroImageView.image = gif

        totoroTextView.string = "Go go go!"
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Update the totoro
        let gif = NSImage(data: self.totoroImageData!)
        totoroImageView.image = gif
        totoroTextView.string = "Loaded! Time to watch anime!"
    }
    
    
}




