//
//  AppDelegate.swift
//  CoronaCounter
//
//  Created by Jiaqi Feng on 4/8/20.
//  Copyright © 2020 Jiaqi Feng. All rights reserved.
//

import Cocoa
import Kanna
import Alamofire
import WebKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        // Insert code here to initialize your application
//        statusItem.menu = statusBarMenu;
//        statusBarMenu.autoenablesItems = true;
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
     
        //statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
    }
}

