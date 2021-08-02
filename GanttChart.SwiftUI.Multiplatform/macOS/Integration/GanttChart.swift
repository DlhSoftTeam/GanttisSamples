//
//  GanttChartView.swift
//  GanttChart.SwiftUI.macOS
//
//  Created by DlhSoft on 25/10/2019.
//

import SwiftUI
import Ganttis

struct GanttChart: NSViewRepresentable {
    typealias NSViewType = Ganttis.GanttChart
    
    let controller: GanttChartController
    
    func makeNSView(context: NSViewRepresentableContext<GanttChart>) -> NSViewType {
        return NSViewType(frame: .zero)
    }
    
    func updateNSView(_ nsView: NSViewType, context: NSViewRepresentableContext<GanttChart>) {
        guard controller !== nsView.controller else { return }
        nsView.controller = controller
    }
}
