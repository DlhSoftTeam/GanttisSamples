//
//  GanttChartViewController.swift
//  GanttChart.ObjC.iOS
//
//  Created by DlhSoft on 21/10/2019.
//

import UIKit
import GanttisTouch

class GanttChartViewController: UIViewController {
    @IBOutlet var ganttChart: GanttChart!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        items[1].completion = 1
        items[2].completion = 0.25
        items[2].type = .summary
        items[4].completion = 0.08
        for i in 3...40 {
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
        items.append(GanttChartItem(row: 3, time: date(6), type: .milestone))
        dependencies.append(GanttChartDependency(from: items[5], to: items.last!))
        let itemSource = GanttChartItemSource(items: items, dependencies: dependencies)
        let headerController = GanttChartHeaderController()
        headerController.rows = [
            GanttChartHeaderRow(.weeks(startingOn: .monday)),
            GanttChartHeaderRow(.days, format: .dayOfWeekShortAbbreviation)]
        let contentController = GanttChartContentController(itemManager: itemSource)
        contentController.intervalHighlighters = [
            TimeSelector(.weeks(startingOn: .monday)), TimeSelector(.time)]
        contentController.scheduleHighlighters = [ScheduleTimeSelector(.weekends)]
        contentController.timeScale = .intervalsWith(period: 15, in: .minutes)
        let controller = GanttChartController(
            headerController: headerController, contentController: contentController)
        ganttChart.controller = controller
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
