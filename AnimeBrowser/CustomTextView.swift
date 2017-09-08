//
//  CustomTextView.swift
//  AnimeBrowser
//
//  Created by Lucy Zhang on 9/8/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import Cocoa

class CustomTextView: NSTextView {
    
    let tableView:NSTableView! = (NSApp.mainWindow?.contentViewController as! ViewController).tableView

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func mouseDown(with event: NSEvent) {
        let row = tableView.row(for: self)
        let index = IndexSet(integer: row)
        tableView.selectRowIndexes(index, byExtendingSelection: false)
    }
    
}
