//
//  ViewController.swift
//  GanttChart.Virtualization.macOS
//
//  Created by DlhSoft on 25/10/2019.
//

import Cocoa
import Ganttis

class ViewController: NSViewController, GanttChartCollectionProvider {
    @IBOutlet var ganttChart: GanttChart!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let itemManager = GanttChartItemManager(collectionProvider: self)
        let headerController = GanttChartHeaderController()
        headerController.rows = [
            GanttChartHeaderRow(.weeks(startingOn: .monday)),
            GanttChartHeaderRow(.days, format: .dayOfWeekShortAbbreviation)]
        let contentController = GanttChartContentController(itemManager: itemManager)
        contentController.intervalHighlighters = [TimeSelector(.weeks)]
        contentController.scheduleHighlighters = [ScheduleTimeSelector(.weekends)]
        contentController.settings.isReadOnly = true
        contentController.preferredTimelineMargin = 0
        let controller = GanttChartController(
            headerController: headerController, contentController: contentController)
        ganttChart.controller = controller
    }
    
    var totalRowCount: Int { return 400_000_000 } // 400 million rows.
    var preferredTimeline: TimeRange {
        let start = Time.reference
        let longTimeAfter = start.adding(weeks: 4_000_000) // About 76,000 years.
        return TimeRange(from: start, to: longTimeAfter)
    }
    // Total: 3.2 quadrillion items (short scale, US), 2 items/week/row.
    func filteredItems(range: RowRange, timeline: TimeRange) -> [GanttChartItem] {
        let weekStart = timeline.start.weekStart
        var items = [GanttChartItem]()
        for row in range.first...range.last {
            for week in -1...Int(timeline.duration.value(in: .weeks) + 1) {
                for day in 0..<6 where day % 3 == 0 {
                    let start = weekStart.adding(weeks: week).adding(days: day + row % 3)
                    let finish = start.adding(days: 2)
                    items.append(GanttChartItem(
                        label: "\(row).\(start.week).\(start.dayOfWeek)",
                        row: row, start: start, finish: finish))
                }
            }
        }
        return items
    }
    func filteredDependencies(range: RowRange,
                              timeline: TimeRange) -> [GanttChartDependency] {
        return []
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

