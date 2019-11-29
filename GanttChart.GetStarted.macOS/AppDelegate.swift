//
//  AppDelegate.swift
//  GanttChart.GetStarted.macOS
//
//  Created by DlhSoft on 31/07/2019.
//

import Cocoa
import Ganttis

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    override init() {
        super.init()
        Ganttis.license = "..."
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        return true
    }
}

