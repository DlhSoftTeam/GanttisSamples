//
//  DataItems.swift
//  OutlineGanttChart.GetStarted.macOS
//
//  Created by DlhSoft on 08/10/2019.
//

import Foundation
import Ganttis

class Row {
    init(chartItems: [ChartItem] = [], children: [Row] = []) {
        self.chartItems = chartItems
        self.children = children
    }
    var chartItems: [ChartItem]
    var children: [Row]
    
    lazy var outlineItem = OutlineGanttChartRow(
        chartItems: chartItems.map { chartItem in chartItem.outlineChartItem },
        context: self)
}

class ChartItem {
    init(label: String? = nil, start: Time, finish: Time, completion: Double = 0,
         attachment: String? = nil, details: String? = nil,
         type: GanttChartItemType? = nil) {
        self.label = label
        self.start = start
        self.finish = finish
        self.completion = completion
        self.attachment = attachment
        self.details = details
        self.type = type ?? .standard
    }
    convenience init(label: String? = nil, time: Time,
                     attachment: String? = nil, details: String? = nil,
                     type: GanttChartItemType? = nil) {
        self.init(label: label, start: time, finish: time, completion: 0,
                  attachment: attachment, details: details, type: type)
    }
    var label: String?
    var start, finish: Time
    var completion: Double
    var attachment: String?
    var details: String?
    var type: GanttChartItemType
    
    lazy var outlineChartItem = OutlineGanttChartItem(
        label: label, start: start, finish: finish, completion: completion,
        attachment: attachment, details: details, type: type, context: self)
}

class ChartDependency {
    init(label: String? = nil, from: ChartItem, to: ChartItem,
         details: String? = nil, type: GanttChartDependencyType? = nil) {
        self.label = label
        self.from = from
        self.to = to
        self.details = details
        self.type = type ?? .fromFinishToStart
    }
    var label: String?
    var from, to: ChartItem
    var details: String?
    var type: GanttChartDependencyType
    
    lazy var outlineChartDependency = OutlineGanttChartDependency(
        label: label, from: from.outlineChartItem, to: to.outlineChartItem,
        details: details, type: type, context: self)
}
