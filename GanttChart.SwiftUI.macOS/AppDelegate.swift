//
//  AppDelegate.swift
//  GanttChart.SwiftUI.macOS
//
//  Created by DlhSoft on 25/10/2019.
//

import Cocoa
import SwiftUI
import Ganttis

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    override init() {
        super.init()
        Ganttis.license = "..."
    }

    var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView().environmentObject(GanttChartAdapter())

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        return true
    }
}

