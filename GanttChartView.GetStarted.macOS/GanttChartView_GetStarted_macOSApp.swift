//
//  GanttChartView_GetStarted_macOSApp.swift
//  GanttChartView.GetStarted.macOS
//
//  Created by DlhSoft on 21.05.2022.
//

import SwiftUI
import Ganttis

@main
struct GanttChartView_GetStarted_macOSApp: App {
    init() {
        Ganttis.license = "..."
    }
    var body: some Scene {
        WindowGroup {
            ContentView().frame(minWidth: 800, minHeight: 400)
        }
    }
}
