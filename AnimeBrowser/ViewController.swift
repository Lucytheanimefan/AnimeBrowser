//
//  ViewController.swift
//  AnimeBrowser
//
//  Created by Lucy Zhang on 9/5/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController {

    @IBOutlet weak var mainWebView: WKWebView!
    
    @IBOutlet weak var leftView: NSView!
    
    @IBOutlet weak var rightView: NSView!
    
    @IBOutlet weak var splitView: NSSplitView!
    
    @IBOutlet weak var tableView: NSTableView!
    
    var sideBarResults:[URL]! = [URL(string:"https://www.animenewsnetwork.com")!]
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

extension ViewController:NSSplitViewDelegate{
    func splitView(_ splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
        return true
    }
    
}

extension ViewController:NSTableViewDelegate, NSTableViewDataSource{
    func numberOfRows(in tableView: NSTableView) -> Int {
        return sideBarResults.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let url = sideBarResults[row]
        let view = CustomCell()
        let req = URLRequest(url: url)
        view.webView.load(req)
        return view
    }

}


