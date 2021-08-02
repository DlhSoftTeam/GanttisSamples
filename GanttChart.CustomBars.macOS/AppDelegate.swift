//
//  AppDelegate.swift
//  GanttChart.CustomBars.macOS
//
//  Created by DlhSoft on 02.08.2021.
//

import Cocoa
import Ganttis

@main
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

