//
//  CustomCell.swift
//  AnimeBrowser
//
//  Created by Lucy Zhang on 9/6/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import Cocoa
import WebKit

class CustomCell: NSTableCellView {
    
    @IBOutlet weak var title: NSTextField!
    
    @IBOutlet weak var subtitle: NSTextField!
    
    @IBOutlet weak var iconView: NSImageView!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
