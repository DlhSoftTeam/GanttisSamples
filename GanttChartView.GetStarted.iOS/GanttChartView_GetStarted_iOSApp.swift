//
//  GanttChartView_GetStarted_iOSApp.swift
//  GanttChartView.GetStarted.iOS
//
//  Created by DlhSoft on 21.05.2022.
//

import SwiftUI
import GanttisTouch

@main
struct GanttChartView_GetStarted_iOSApp: App {
    init() {
        GanttisTouch.license = "..."
    }
    var body: some Scene {
        WindowGroup {
            NavigationView {
            ContentView().navigationBarHidden(true)
            }
            .navigationViewStyle(.stack)
            .statusBar(hidden: ProcessInfo.processInfo.isiOSAppOnMac)
        }
    }
}
