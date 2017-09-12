//
//  WindowController.swift
//  AnimeBrowser
//
//  Created by Lucy Zhang on 9/5/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

//Anime browser feature requests:
//- the ability to search series by random descriptors for characters and scenes that I vaguely remember and may actually be completely unrelated to the anime I am thinking of
//- every 25 phrases, it switches to a random fanboy's really bad rendition of lelouch's voice instead
//- I guess I would use an anime broswer if it had a lot of integrations?
//- maybe have a waifu feature that's really just a modified clippy
//- makes comments about your browsing
//- Updates on things I'm watching
//- Easy-access repository of things I have watched
//- Download option for offline viewing
//    - Nice icons/library system of organization

import Cocoa
import AppKit
import WebKit

class WindowController: NSWindowController {
    @IBOutlet weak var toolBar: NSToolbar!

    @IBOutlet var browserHeaderView: NSView!
    
    @IBOutlet weak var urlField: NSTextField!
    
    @IBOutlet weak var backButton: NSButton!
    
    var urlBackQueue:[URL] = [URL]()
    var urlForwardQueue:[URL] = [URL]()
    
    var tabURLs:[URL] = [URL]()
    
    let BrowserHeaderToolbarID = "BrowserHeaderID"
    
    let animeSites = ["CrunchyRoll": "http://www.crunchyroll.com/","Funimation": "https://www.funimation.com/", "ANN": "https://www.animenewsnetwork.com", "MAL": "https://www.myanimelist.net", "Reddit": "https://www.reddit.com/r/anime", "AnimeMaru": "http://www.animemaru.com"]
    
    
    let idToEndpoint = ["RAAnime":Requester.recentlyAddedAnimeID, "RAManga":Requester.recentlyAddedMangaID, "RACompanies":Requester.recentlyAddedCompaniesID, "Ratings":Requester.ratingsID]
    
    let requester = Requester()
    
    @IBOutlet weak var sideBarSelectionButton: NSPopUpButton!
    
    override func windowDidLoad() {
        super.windowDidLoad()

        self.toolBar.allowsUserCustomization = true
        self.toolBar.autosavesConfiguration = true
        self.toolBar.displayMode = .iconOnly
    }
    
    @IBAction func submitURLString(_ sender: NSTextField) {
        // TODO: do this more intelligently
        var string = sender.stringValue
        var url:URL!
        if (!string.hasPrefix("https://www.") && !string.hasPrefix("http://www.")) {
            // We must always search about anime!
            if (!string.contains("anime")){ string = string + " anime" }
            string = googleSearchURL + string.replacingOccurrences(of: " ", with: "+")
        }
        url = URL(string: string)
        if (url != self.urlBackQueue.last){
            self.urlBackQueue.append(url!)
            openURL(url: url!)
        }
    }
    
    @IBAction func openAnimeSite(_ sender: NSButton) {
        if let urlString = animeSites[sender.identifier!]{
            let url = URL(string:urlString)
            self.urlField.stringValue = urlString
            openURL(url: url!)
        }
    }
    
    @IBAction func goBack(_ sender: NSButton) {
        let url = self.urlBackQueue.removeLast()
        print("Back url: ")
        print(url)
        print(self.urlBackQueue)
        self.urlField.stringValue = url.absoluteString
        self.urlForwardQueue.append(url)
        openURL(url: url)
    }
    
    @IBAction func sideBarSelection(_ sender: NSPopUpButton) {
        let id = sender.selectedItem?.identifier
        let endpoint = idToEndpoint[id!]
        requester.makeRequest(endpoint: endpoint!, parameters: nil, type: "GET") { (data) in
            if let vc = self.window?.contentViewController as? ViewController{
                print(data)
                vc.recentlyAddedAnime = data
                DispatchQueue.main.async {
                    vc.tableView.reloadData()
                }

            }
        }
    }
    
    @IBAction func goForward(_ sender: NSButton) {
        print("Forward url: ")
        if (self.urlForwardQueue.count > 0){
            let url = self.urlForwardQueue.removeLast()
            print(url)
            print(self.urlForwardQueue)
            self.urlField.stringValue = url.absoluteString
            self.urlBackQueue.append(url)
            openURL(url: url)
        }
    }
    
    @IBAction func createNewTab(_ sender: NSButton) {
        // Just create a new webview
        if let vc = self.window?.contentViewController as? ViewController{
            // Save the state of the old one
            let savedURL = vc.mainWebView.url
            self.tabURLs.append(savedURL!)
            
            // Reset the webview
            // vc.mainWebView = WKWebView.init(frame: vc.mainWebView.visibleRect)
        }
        
    }
    
    
    @IBAction func bookButtonAction(_ sender: NSButton) {
    }
    
    
    func openURL(url:URL){
        if let vc = self.window?.contentViewController as? ViewController{
            let req = URLRequest(url: url)
            print(url)
            vc.mainWebView.load(req)
//            while (vc.mainWebView.isLoading){
//                print("Still loading")
//            }
//            print("Done loading!")
        }
    }
    
    
    func customToolbarItem(itemForItemIdentifier itemIdentifier: String, label: String, paletteLabel: String, toolTip: String, target: AnyObject, itemContent: AnyObject, action: Selector?, menu: NSMenu?) -> NSToolbarItem? {
        
        let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
        
        toolbarItem.label = label
        toolbarItem.paletteLabel = paletteLabel
        toolbarItem.toolTip = toolTip
        toolbarItem.target = target
        toolbarItem.action = action
        
        // Set the right attribute, depending on if we were given an image or a view.
        if (itemContent is NSImage) {
            let image: NSImage = itemContent as! NSImage
            toolbarItem.image = image
        }
        else if (itemContent is NSView) {
            let view: NSView = itemContent as! NSView
            toolbarItem.view = view
        }
        else {
            assertionFailure("Invalid itemContent: object")
        }
        
        /* If this NSToolbarItem is supposed to have a menu "form representation" associated with it
         (for text-only mode), we set it up here.  Actually, you have to hand an NSMenuItem
         (not a complete NSMenu) to the toolbar item, so we create a dummy NSMenuItem that has our real
         menu as a submenu.
         */
        // We actually need an NSMenuItem here, so we construct one.
        let menuItem: NSMenuItem = NSMenuItem()
        menuItem.submenu = menu
        menuItem.title = label
        toolbarItem.menuFormRepresentation = menuItem
        
        return toolbarItem
    }

    
}

extension WindowController:NSToolbarDelegate {
    /**
     NSToolbar delegates require this function.
     It takes an identifier, and returns the matching NSToolbarItem. It also takes a parameter telling
     whether this toolbar item is going into an actual toolbar, or whether it's going to be displayed
     in a customization palette.
     */
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: String, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        
        var toolbarItem: NSToolbarItem = NSToolbarItem()
        
        /* We create a new NSToolbarItem, and then go through the process of setting up its
         attributes from the master toolbar item matching that identifier in our dictionary of items.
         */
        if (itemIdentifier == BrowserHeaderToolbarID) {
            // 1) Font style toolbar item.
            toolbarItem = customToolbarItem(itemForItemIdentifier: BrowserHeaderToolbarID, label: "Browser Header", paletteLabel:"Browser header", toolTip: "Browser header", target: self, itemContent: self.browserHeaderView, action: nil, menu: nil)!
        }
        
        return toolbarItem
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
        
        return [BrowserHeaderToolbarID]

    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
        
        return [ BrowserHeaderToolbarID,
                 NSToolbarSpaceItemIdentifier,
                 NSToolbarFlexibleSpaceItemIdentifier,
                 NSToolbarPrintItemIdentifier ]
    }
}

