//
//  GanttChartView.swift
//  GanttChart.SwiftUI.iOS
//
//  Created by DlhSoft on 25/10/2019.
//

import SwiftUI
import GanttisTouch

struct GanttChart: UIViewRepresentable {
    typealias UIViewType = GanttisTouch.GanttChart
    
    let controller: GanttChartController
    
    func makeUIView(context: UIViewRepresentableContext<GanttChart>) -> UIViewType {
        return UIViewType(frame: .zero)
    }
    
    func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<GanttChart>) {
        guard controller !== uiView.controller else { return }
        uiView.controller = controller
    }
}
