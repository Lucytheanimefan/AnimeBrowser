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
    
    var recentlyAddedAnime:[[String:Any]]! = [[String:Any]]()
    
    var sideBarResults:[URL]! = [URL(string:"https://www.animenewsnetwork.com")!, URL(string:"https://www.myanimelist.net")!]
    
    var count:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTotoroGIF()
        
        let requester = Requester()
        requester.makeRequest(endpoint: Requester.recentlyAddedAnimeID, parameters: nil, type: "GET") { (data) in
            print("Entered completion")
            self.recentlyAddedAnime = data
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
        totoroTextView.string = "Watch anime"
//        var imageData:Data!
//        do{
//            imageData = try Data(contentsOf: Bundle.main.url(forResource: "totoro_transparent", withExtension: "gif")!)
//        }
//        catch {
//            print(error)
//            return
//        }
        totoroImageView.animates = true
        let advTimeGif = NSImage(data: self.totoroImageData!)
        totoroImageView.image = advTimeGif
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
        return self.recentlyAddedAnime.count
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
        let dict = self.recentlyAddedAnime[row]
        
        if let view = tableView.make(withIdentifier: "webCell", owner: nil) as? CustomCell{
            if let anime = dict["anime"] as? String{
                //print(anime)
                view.titleView.string = anime
                return view
            }
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = tableView.selectedRow
        let dict = self.recentlyAddedAnime[row]
        if let urlString = dict["href"] as? String{
            let url = URL(string:(Requester.ANN + urlString))!
            let req = URLRequest(url: url)
            mainWebView.load(req)
            totoroTextView.string = "Let's go load!"
        }
    }
    
}

extension ViewController: WKNavigationDelegate{
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        (NSApp.mainWindow?.windowController as! WindowController).urlBackQueue.append(webView.url!)
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


