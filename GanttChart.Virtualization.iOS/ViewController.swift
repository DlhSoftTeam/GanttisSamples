//
//  ViewController.swift
//  GanttChart.Virtualization.iOS
//
//  Created by DlhSoft on 25/10/2019.
//

import UIKit
import GanttisTouch

class ViewController: UIViewController, GanttChartCollectionProvider {
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
    
    var totalRowCount: Int { return 80 }
    var preferredTimeline: TimeRange {
        let currentWeekStart = Time().weekStart
        let longTimeAfter = currentWeekStart.adding(weeks: 8)
        return TimeRange(from: currentWeekStart, to: longTimeAfter)
    }
    func filteredItems(range: RowRange, timeline: TimeRange) -> [GanttChartItem] {
        let weekStart = timeline.start.weekStart
        var items = [GanttChartItem]()
        for row in range.first...range.last {
            for week in -1...Int(timeline.duration.value(in: .weeks) + 1) {
                for day in 0..<6 where day % 3 == 0 {
                    let start = weekStart.adding(weeks: week).adding(days: day + row % 3)
                    let finish = start.adding(days: 2)
                    items.append(GanttChartItem(row: row, start: start, finish: finish))
                }
            }
        }
        return items
    }
    func filteredDependencies(range: RowRange,
                              timeline: TimeRange) -> [GanttChartDependency] {
        return []
    }


}

