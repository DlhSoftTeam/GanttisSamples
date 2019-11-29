//
//  GanttChartAdapter.swift
//  GanttChart.SwiftUI.macOS
//
//  Created by DlhSoft on 02/11/2019.
//

import SwiftUI
import Ganttis

class GanttChartAdapter: ObservableObject, GanttChartItemObserver {
    let controller: GanttChartController
    @Published var lastChange: String = "none"
    
    init() {
        func date(_ day: Int) -> Time {
            return Time().weekStart.adding(days: day)
        }
        var items = [
            GanttChartItem(label: "A", row: 0, start: date(1), finish: date(2)),
            GanttChartItem(label: "B", row: 1, start: date(1), finish: date(3)),
            GanttChartItem(label: "C", row: 1, start: date(4), finish: date(6)),
            GanttChartItem(row: 1, start: date(10), finish: date(11)),
            GanttChartItem(row: 2, start: date(2), finish: date(12))]
        items.first!.style.barFillColor = .darkGreen
        items.last!.details = "Special item"
        items[1].completion = 1
        items[2].completion = 0.25
        items[2].type = .summary
        items[4].completion = 0.08
        for i in 3..<100 {
            items.append(GanttChartItem(label: String(i), row: i,
                                        start: date(i), finish: date(i + 1)))
        }
        items[6].attachment = "R"
        var dependencies = [
            GanttChartDependency(from: items[2], to: items[4]),
            GanttChartDependency(from: items[5], to: items[6], type: .fromStartToStart),
            GanttChartDependency(from: items[7], to: items[8], type: .fromFinishToFinish),
            GanttChartDependency(from: items[9], to: items[10], type: .fromStartToFinish)]
        dependencies.first!.style.lineColor = .darkGreen
        dependencies.last!.details = "Special dependency"
        items.append(GanttChartItem(row: 3, time: date(6), type: .milestone))
        dependencies.append(GanttChartDependency(from: items[5], to: items.last!))
        let itemSource = GanttChartItemSource(items: items, dependencies: dependencies)
        let headerController = GanttChartHeaderController()
        headerController.rows = [
            GanttChartHeaderRow(.weeks(startingOn: .monday)),
            GanttChartHeaderRow(.days, format: .dayOfWeekShortAbbreviation)]
        headerController.rowSelector = GanttChartHeaderRowSource { hourWidth in
            if hourWidth < 2 {
                return [
                    GanttChartHeaderRow(.months),
                    GanttChartHeaderRow(.weeks(startingOn: .monday))]
            }
            return nil
        }
        let contentController = GanttChartContentController(itemManager: itemSource)
        contentController.intervalHighlighters = [
            TimeSelector(.weeks(startingOn: .monday)), TimeSelector(.time)]
        contentController.scheduleHighlighters = [ScheduleTimeSelector(.weekends)]
        contentController.timeScale = .intervalsWith(period: 15, in: .minutes)
        contentController.settings.allowsEditingElements = true
        contentController.settings.allowsEditingDependencies = false
        self.controller = GanttChartController(
            headerController: headerController, contentController: contentController)
        itemSource.itemObserver = self
    }
    
    func changeBackgroundColor() {
        controller.contentController.style.backgroundColor = .blue
        controller.contentController.settingsDidChange()
    }
    
    func timeDidChange(for item: GanttChartItem, from originalValue: TimeRange) {
        lastChange = item.label ?? "item"
    }
    func completionDidChange(for item: GanttChartItem, from originalValue: Double) {
        lastChange = item.label ?? "item"
    }
    func rowDidChange(for item: GanttChartItem, from originalValue: Row) {
        lastChange = item.label ?? "item"
    }
    func itemWasAdded(_ item: GanttChartItem) {
        lastChange = item.label ?? "new item"
    }
}
