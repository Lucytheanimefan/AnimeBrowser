//
//  AppDelegate.swift
//  AnimeBrowser
//
//  Created by Lucy Zhang on 9/5/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var windowController : WindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func newWindow(_ sender: Any) {
        
        //createNewWindow()
        //newWindow.windowController
    }
    
    func createNewWindow() {
        var newWindow:NSWindow! //NSWindow(contentRect: NSMakeRect(0, 0, NSScreen.main()!.frame.midX, NSScreen.main()!.frame.midY), styleMask: [.closable], backing: .buffered, defer: false)
        //newWindow.title = "New Window"
        //newWindow.isOpaque = false
        
        //let storyboard = NSStoryboard(name: "Main", bundle: nil)
        if let controller = ViewController(nibName: nil, bundle: Bundle.main){
            //if let controller = storyboard.instantiateController(withIdentifier: "viewControllerID") as? NSViewController{
            newWindow = NSWindow(contentViewController: controller)
            newWindow.center()
            newWindow.isMovableByWindowBackground = true
            //newWindow.backgroundColor = NSColor(calibratedHue: 0, saturation: 1.0, brightness: 0, alpha: 0.7)
            newWindow.makeKeyAndOrderFront(nil)
            
            let windowController = WindowController(window: newWindow)
            
            windowController.showWindow(self)
        }
        
        //}
        
    }

}

