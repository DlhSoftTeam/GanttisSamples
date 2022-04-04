//
//  GanttChartAdapter.swift
//  GanttChart.SwiftUI.iOS
//
//  Created by DlhSoft on 02/11/2019.
//

import SwiftUI
import GanttisTouch

class GanttChartAdapter: ObservableObject, GanttChartItemObserver {
    let controller: GanttChartController
    @Published var lastChange: String = "none"
    
    init(items: [Item], dependencies: [Dependency]) {
        func date(_ day: Int) -> Time {
            return Time().weekStart.adding(days: day)
        }
        func ganttChartItemType(_ source: ItemType) -> GanttChartItemType {
            switch source {
            case .standard:
                return .standard
            case .milestone:
                return .milestone
            case .summary:
                return .summary
            }
        }
        func color(_ source: Color?) -> GanttisTouch.Color? {
            guard let source = source else { return nil }
            return GanttisTouch.Color(red: source.red, green: source.green, blue: source.blue,
                                      alpha: source.alpha)
        }
        func ganttChartItemStyle(_ source: ItemStyle) -> GanttChartItemStyle {
            GanttChartItemStyle(barFillColor: color(source.barFillColor))
        }
        func ganttChartItem(_ source: Item) -> GanttChartItem {
            GanttChartItem(label: source.label, row: source.row,
                           start: date(source.start), finish: date(source.finish),
                           completion: source.completion, attachment: source.attachment,
                           details: source.details, type: ganttChartItemType(source.type),
                           style: ganttChartItemStyle(source.style),
                           context: source)
        }
        func ganttChartDependencyType(_ source: DependencyType) -> GanttChartDependencyType {
            switch source {
            case .fromFinishToStart:
                return .fromFinishToStart
            case .fromStartToStart:
                return .fromStartToStart
            case .fromFinishToFinish:
                return .fromFinishToFinish
            case .fromStartToFinish:
                return .fromStartToFinish
            }
        }
        func ganttChartDependencyStyle(_ source: DependencyStyle) -> GanttChartDependencyStyle {
            GanttChartDependencyStyle(lineColor: color(source.lineColor))
        }
        func ganttChartDependency(_ source: Dependency, using items: [GanttChartItem]) -> GanttChartDependency {
            GanttChartDependency(from: items.first { item in item.context as! Item === source.from }!,
                                 to: items.first { item in item.context as! Item === source.to }!,
                                 details: source.details, type: ganttChartDependencyType(source.type),
                                 style: ganttChartDependencyStyle(source.style))
        }
        let items = items.map { item in ganttChartItem(item) }
        let dependencies = dependencies.map { dependency in ganttChartDependency(dependency, using: items) }
        let itemSource = GanttChartItemSource(items: items, dependencies: dependencies)
        let headerController = GanttChartHeaderController()
        headerController.rows = [
            GanttChartHeaderRow(.weeks(startingOn: .monday)),
            GanttChartHeaderRow(.days, format: .dayOfWeekShortAbbreviation)]
        headerController.rowSelector = GanttChartHeaderRowSource { hourWidth in
            if hourWidth < 2.25 {
                return [
                    GanttChartHeaderRow(.months),
                    GanttChartHeaderRow(.weeks(startingOn: .monday))]
            }
            return nil
        }
        let contentController = GanttChartContentController(itemManager: itemSource)
        let weekStart = Time.current.weekStart
        contentController.scrollableTimeline =
            TimeRange(from: weekStart, to: weekStart.adding(weeks: 5))
        contentController.intervalHighlighters = [
            TimeSelector(.weeks(startingOn: .monday)), TimeSelector(.time)]
        contentController.scheduleHighlighters = [ScheduleTimeSelector(.weekends)]
        contentController.timeScale = .intervalsWith(period: 15, in: .minutes)
        contentController.settings.allowsEditingElements = true
        contentController.settings.allowsEditingDependencies = false
        let controller = GanttChartController(
            headerController: headerController, contentController: contentController)
        self.controller = controller
        itemSource.itemObserver = self
    }
    
    func changeBackgroundColor() {
        controller.contentController.style.backgroundColor = .blue
        controller.contentController.settingsDidChange()
    }
    
    func timeDidChange(for item: GanttChartItem, from originalValue: TimeRange) {
        let item = item.context as! Item
        lastChange = item.label ?? "item"
    }
    func completionDidChange(for item: GanttChartItem, from originalValue: Double) {
        let item = item.context as! Item
        lastChange = item.label ?? "item"
    }
    func rowDidChange(for item: GanttChartItem, from originalValue: Row) {
        let item = item.context as! Item
        lastChange = item.label ?? "item"
    }
    func itemWasAdded(_ item: GanttChartItem) {
        let item = item.context as! Item
        lastChange = item.label ?? "new item"
    }
}

func date(_ day: Int) -> Time {
    return Time().weekStart.adding(days: day)
}
