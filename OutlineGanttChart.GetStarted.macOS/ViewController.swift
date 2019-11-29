//
//  ViewController.swift
//  OutlineGanttChart.GetStarted.macOS
//
//  Created by DlhSoft on 08/10/2019.
//

import Cocoa
import Ganttis

class ViewController: NSViewController, OutlineGanttChartDataSource {
    @IBOutlet var outlineGanttChart: OutlineGanttChart!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let now = Time.current
        // Row hierarchy, with chart items and child rows
        rows = [
            Row(
                chartItems: [
                    ChartItem(
                        label: "Task 1",
                        start: now, finish: now.adding(days: 3),
                        details: "Task 1 details",
                        type: .summary)],
                children: [
                    Row(
                        chartItems: [
                            ChartItem(
                                label: "Task 1.1",
                                start: now, finish: now.adding(days: 2),
                                completion: 0.5, attachment: "Resource 1",
                                details: "Task 1.1 details"),
                            ChartItem(
                                time: now.adding(days: 3), type: .milestone)])]),
            Row(
                chartItems: [
                    ChartItem(
                        label: "Task 2",
                        start: now.adding(days: 1), finish: now.adding(days: 4),
                        completion: 0.25, attachment: "Resource 2",
                        details: "Task 2 details")])]
        // Add more rows dynamically
        for i in 3...400 {
            rows.append(Row(
                chartItems: [ChartItem(
                    label: "Task \(i)",
                    start: now.adding(hours: Double(i * 4)),
                    finish: now.adding(hours: Double(i * 9)),
                    type: i % 2 == 0 ? .summary : nil)],
                children: i % 2 == 0 ? [
                    Row(
                        chartItems: [
                            ChartItem(
                                label: "Task \(i).1",
                                start: now.adding(hours: Double(i * 4)),
                                finish: now.adding(hours: Double(i * 8)))]),
                    Row(
                        chartItems: [
                            ChartItem(
                                label: "Task \(i).2",
                                start: now.adding(hours: Double(i * 4)),
                                finish: now.adding(hours: Double(i * 9)))])] : []))
        }
        // Add more child rows dynamically to Task 4
        for i in 3...15 {
            rows[3].children.append(Row(
                chartItems: [ChartItem(
                    label: "Task 4.\(i)",
                    start: now.adding(hours: Double(i * 4)),
                    finish: now.adding(hours: Double(i * 9)),
                    type: i % 2 == 0 ? .summary : nil)],
                children: i % 2 == 0 ? [
                    Row(
                        chartItems: [
                            ChartItem(
                                label: "Task 4.\(i).1",
                                start: now.adding(hours: Double(i * 4)),
                                finish: now.adding(hours: Double(i * 8)))]),
                    Row(
                        chartItems: [
                            ChartItem(
                                label: "Task 4.\(i).2",
                                start: now.adding(hours: Double(i * 4)),
                                finish: now.adding(hours: Double(i * 9)))])] : []))
        }
        rows[3].chartItems[0].start = now.adding(hours: 3 * 4)
        rows[3].chartItems[0].finish = now.adding(hours: 15 * 9)
        // Dependencies between chart items
        chartDependencies = [
            ChartDependency(
                from: rows[0].children[0].chartItems[0],
                to: rows[1].chartItems[0],
                type: .fromStartToStart),
            ChartDependency(
                from: rows[0].children[0].chartItems[0],
                to: rows[0].children[0].chartItems[1]),
            ChartDependency(
                from: rows[1].chartItems[0],
                to: rows[2].chartItems[0])]
        for i in stride(from: 3, to: rows.count / 2, by: 2) {
            chartDependencies.append(ChartDependency(
                from: rows[i - 1].chartItems[0],
                to: rows[i].chartItems[0]))
        }
        // Outline view table columns
        outlineColumn.title = "Tasks"
        outlineColumn.width = 120
        outlineColumn.minWidth = 120
        startColumn.title = "Start"
        startColumn.minWidth = 120
        startColumnCell.font =
            NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        outlineView.addTableColumn(startColumn)
        finishColumn.title = "Finish"
        finishColumn.minWidth = 120
        finishColumnCell.font =
            NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        outlineView.addTableColumn(finishColumn)
        completionColumn.title = "Compl. (%)"
        completionColumn.width = 60
        completionColumnCell.alignment = .right
        completionColumnCell.font =
            NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        outlineView.addTableColumn(completionColumn)
        attachmentColumn.title = "Assignments"
        outlineView.addTableColumn(attachmentColumn)
        detailsColumn.title = "Details"
        detailsColumn.minWidth = 120
        outlineView.addTableColumn(detailsColumn)
        // Date-time formatting
        dateFormatter.timeZone = Time.calendar.timeZone
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        // Gantt chart timeline
        ganttChartContentController.scrollableTimeline =
            TimeRange(from: now.adding(days: -1), to: now.adding(weeks: 5))
        ganttChartContentController.intervalHighlighters = [
            TimeSelector(.weeks), TimeSelector(.time)]
        ganttChartContentController.scheduleHighlighters = [ScheduleTimeSelector(.weekends)]
        ganttChartContentController.timeScale = .intervalsWith(period: 15, in: .minutes)
        // Gantt chart headers
        ganttChartHeaderController.rows = [
            GanttChartHeaderRow(.months), GanttChartHeaderRow(.weeks),
            GanttChartHeaderRow(.days, format: .dayOfWeekShortAbbreviation)]
        // Title
        outlineHeaderSpacingLabel.stringValue = "My project"
        // Data
        outlineGanttChart.dataSource = self
        outlineGanttChart.isPagingEnabled = true
        // Schedule and behavior (optional)
        // outlineGanttChart.schedule = .standard
        // outlineGanttChart.autoApplySchedule = true
        // outlineGanttChart.isAutoScheduling = true
        // outlineGanttChart.autoApplyBehavior = true
    }
    
    // Component helpers
    var splitView: NSSplitView { return outlineGanttChart.splitView }
    var outlineView: NSOutlineView { return outlineGanttChart.outlineView }
    var outlineHeaderSpacingLabel: NSTextField {
        return outlineGanttChart.outlineHeaderSpacingLabel }
    var outlineColumn: NSTableColumn { return outlineView.outlineTableColumn! }
    let startColumn = NSTableColumn(), finishColumn = NSTableColumn()
    let completionColumn = NSTableColumn(), attachmentColumn = NSTableColumn()
    let detailsColumn = NSTableColumn()
    var startColumnCell: NSCell { return startColumn.dataCell as! NSCell }
    var finishColumnCell: NSCell { return finishColumn.dataCell as! NSCell }
    var completionColumnCell: NSCell { return completionColumn.dataCell as! NSCell }
    var dateFormatter = DateFormatter()
    var numberFormatter = NumberFormatter()
    var ganttChart: GanttChart { return outlineGanttChart.ganttChart }
    var ganttChartController: GanttChartController { return ganttChart.controller }
    var ganttChartHeaderController: GanttChartHeaderController {
        return ganttChartController.headerController }
    var ganttChartContentController: GanttChartContentController {
        return ganttChartController.contentController }
    
    // Data store
    var rows: [Row]!
    var chartDependencies: [ChartDependency]!
    
    // OutlineGanttChartDataSource
    func outlineGanttChart(_ outlineGanttChart: OutlineGanttChart, child index: Int, ofItem item: OutlineGanttChartRow?) -> OutlineGanttChartRow {
        let localItem = item == nil ? rows[index]
            : (item!.context as! Row).children[index]
        return localItem.outlineItem
    }
    func outlineGanttChart(_ outlineGanttChart: OutlineGanttChart, isItemExpandable item: OutlineGanttChartRow) -> Bool {
        return (item.context as! Row).children.count > 0
    }
    func outlineGanttChart(_ outlineGanttChart: OutlineGanttChart, numberOfChildrenOfItem item: OutlineGanttChartRow?) -> Int {
        return item == nil ? rows.count
            : (item!.context as! Row).children.count
    }
    func outlineGanttChart(_ outlineGanttChart: OutlineGanttChart, objectValueFor tableColumn: NSTableColumn?, byItem item: OutlineGanttChartRow?) -> Any? {
        let item = item!, chartItem = item.chartItems[0]
        switch tableColumn {
        case startColumn:
            return dateFormatter.string(from: chartItem.start)
        case finishColumn:
            return dateFormatter.string(from: chartItem.finish)
        case completionColumn:
            return String(format: "%.2f", chartItem.completion * 100)
        case attachmentColumn:
            return chartItem.attachment
        case detailsColumn:
            return chartItem.details
        default:
            return chartItem.label
        }
    }
    func outlineGanttChart(_ outlineGanttChart: OutlineGanttChart, setObjectValue object: Any?, for tableColumn: NSTableColumn?, byItem item: OutlineGanttChartRow?) {
        let item = item!, chartItem = item.chartItems[0]
        let localChartItem = chartItem.context as! ChartItem
        switch tableColumn {
        case startColumn:
            guard let time = dateFormatter.dateTime(from: object as! String) else { return }
            chartItem.start = time
            outlineGanttChart.applySchedule(for: chartItem)
            outlineGanttChart.applyBehavior(for: chartItem)
            localChartItem.start = chartItem.start
        case finishColumn:
            guard let time = dateFormatter.dateTime(from: object as! String) else { return }
            chartItem.finish = time
            outlineGanttChart.applySchedule(for: chartItem)
            outlineGanttChart.applyBehavior(for: chartItem)
            localChartItem.finish = chartItem.finish
        case completionColumn:
            guard let percent = Double(object as! String) else { return }
            chartItem.completion = max(0, min(1, percent / 100))
            outlineGanttChart.applyBehavior(for: chartItem)
            localChartItem.completion = chartItem.completion
        case attachmentColumn:
            chartItem.attachment = object as? String
            localChartItem.attachment = chartItem.attachment
        case detailsColumn:
            chartItem.details = object as? String
            localChartItem.details = chartItem.details
        default:
            chartItem.label = object as? String
            localChartItem.label = chartItem.label
        }
    }
    func outlineGanttChart(_ outlineGanttChart: OutlineGanttChart, dependenciesFor items: [OutlineGanttChartItem]) -> [OutlineGanttChartDependency] {
        return chartDependencies.map { dependency in dependency.outlineChartDependency }
            .filter { dependency in
                items.contains { item in item === dependency.from || item === dependency.to }
        }
    }
    func outlineGanttChart(_ outlineGanttChart: OutlineGanttChart, timeDidChangeFor item: OutlineGanttChartItem, from originalValue: TimeRange) {
        let localChartItem = item.context as! ChartItem
        localChartItem.start = item.start
        localChartItem.finish = item.finish
    }
    func outlineGanttChart(_ outlineGanttChart: OutlineGanttChart, completionDidChangeFor item: OutlineGanttChartItem, from originalValue: Double) {
        let localChartItem = item.context as! ChartItem
        localChartItem.completion = item.completion
    }
    func outlineGanttChart(_ outlineGanttChart: OutlineGanttChart, didAddDependency dependency: OutlineGanttChartDependency) {
        let localChartDependency = ChartDependency(
            label: dependency.label,
            from: dependency.from.context as! ChartItem,
            to: dependency.to.context as! ChartItem,
            details: dependency.details,
            type: dependency.type)
        chartDependencies.append(localChartDependency)
        dependency.context = localChartDependency
        outlineGanttChart.applyBehavior(for: dependency.from)
    }
    func outlineGanttChart(_ outlineGanttChart: OutlineGanttChart, didRemoveDependency dependency: OutlineGanttChartDependency) {
        chartDependencies.removeAll { localChartDependency in
            localChartDependency === dependency.context as! ChartDependency
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

