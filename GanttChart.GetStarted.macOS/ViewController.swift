//
//  ViewController.swift
//  GanttChart.GetStarted.macOS
//
//  Created by DlhSoft on 31/07/2019.
//

import Cocoa
import Ganttis

class ViewController: NSViewController {
    @IBOutlet var ganttChart: GanttChart!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Initialize items to be displayed as Gantt chart bars by specifying, for each of them, a label (text) to be presented over the item's rectangle, a row to indicate its vertical position, start and finish times to indicate the interval spanned horizontally, and optionally a completion rate (triggering a secondary bar presented on top of the item's rectangle, from the same start time, visually indicating effort completion), an attachment value (text presented to the right side of the item's rectangle, such as a resource assignment), and details (text presented as a tooltip for the item).
        var items: [GanttChartItem] = []
        for i in 0..<100 {
            let item = GanttChartItem(
                label: "Item \(i + 1)",
                row: i,
                start: Time.current.weekStart.adding(days: i),
                finish: Time.current.weekStart.adding(days: i * 2 + 1),
                completion: Double(i) / 100,
                attachment: "Resource \(i % 3 + 1)",
                details: "Details for item \(i + 1)")
            // Optionally, set up individual behavioral and appearance settings (style properties) for any item.
            if i == 3 {
                item.label = "M"
                item.finish = item.start
                item.type = .milestone
                item.details =  "\(item.details!) (milestone)"
                item.style.barFillColor = .orange
            }
            if i == 4 {
                item.settings.isReadOnly = true
                item.details = "\(item.details!) (read only)"
            }
            if i % 2 == 0 {
                item.style.barFillColor = .darkGreen
                // Optionally, define the secondary bar fill color for an item to generate a gradient.
                if i % 4 == 0 {
                    item.style.secondaryBarFillColor = .brown
                }
            }
            items.append(item)
        }
        
        // Initialize dependencies representing relations between items displayed as line arrows between Gantt chart bars by specifying from and to item references, and optionally details (text presented as a tooltip for the dependency).
        var dependencies: [GanttChartDependency] = []
        for i in 3..<100 {
            let dependency = GanttChartDependency(
                from: items[i - 1],
                to: items[i],
                details: "Dependency from item \(i) to item \(i + 1)")
            // Optionally, set up individual behavioral and appearance settings (style properties) for any dependency.
            if i == 7 {
                dependency.settings.isReadOnly = true
                dependency.details = "\(dependency.details!) (read only)"
            }
            if i % 3 == 0 {
                dependency.style.lineColor = .darkGreen
            }
            dependencies.append(dependency)
        }
        
        // Define a Gantt chart item manager instance, such as a GanttChartItemSource that wraps up items and their dependencies, to provide data when the view requires it (through its associated controller). A custom GanttChartItemManager instance instead would allow you to optimize data loading even further, as it offers full (low level) vertical and horizontal virtualization support.
        let itemManager = GanttChartItemSource(items: items, dependencies: dependencies)
        
        // Optionally, define a schedule for the items to respect, if needed. The built-in schedule definitions are: conitnuous (Sun-Sat 00-24), standard (Mon-Fri 08-16), fullWeek (Sun-Sat 08-16), and fullDay (Mon-Fri 00-24). You can also define custom schedule objects by calling Schedule initializer and providing the week and day intervals to use and custom intervals to be excluded (or rules to define such exclusions.) Individual items can also override the main schedule. Finally, you may call applySchedule to ensure the schedule settings are enforced to the current items immediately, as well.
        itemManager.schedule = .fullDay
        items[5].schedule = .continuous
        items[5].details = "\(items[5].details!) (continuous schedule)"
        items[6].schedule = Schedule(
            weekInterval: WeekRange(from: .tuesday, to: .thursday),
            dayInterval: DayRange(from: TimeOfDay(from: 10, in: .hours),
                                  to: TimeOfDay(from: 14, in: .hours)),
            excludedIntervals: [TimeRange(from: Time.current.weekStart,
                                          to: Time.current.weekStart.adding(days: 4))])
        items[6].details = "\(items[5].details!) (custom schedule)"
        itemManager.applySchedule()
        
        // Optionally, auto-schedule items based on their dependencies using a specific behavior initialized by setting isAutoScheduling property to true. Other behaviors can also be set up: for example, setting isColumn to true ensures only one item in the collection uses any row index in the chart area (thus the items being presented as a column), and calling hierarchicalRelations allows defining parent items (usually set up as summary type) and their children, having their time properties synchronized automatically at runtime. Note that the order of these settings is important: ensure auto-scheduling is set up after defining any hierarchical relations. Finally, you may call applyBehavior to ensure the resulting behavior (combining column mode, hierarchical relations, auto-scheduling) is enforced to the current items immediately, as well.
        itemManager.isColumn = true
        // items[0].type = .summary
        // items[0].style.barFillColor = .gray
        // items[0].style.secondaryBarFillColor = nil
        // itemManager.hierarchicalRelations = [
        //     GanttChartItemHierarchicalRelation(parent: items[0],
        //                                        children: [items[1], items[2]])]
        // itemManager.isAutoScheduling = true
        // itemManager.applyBehavior()
        
        // Initialize a Gantt Chart header controller specifying settings for the chart header: rows array defines the scales to be displayed on top of the chart, each of them having its own settings and possibly formatting (rowSelector can also be used instead, to apply different sets of headers depending on the zoom level.) Some of the built-in header row types are: decades, years, quarters, months, weeks, days, hours, minutes, and seconds (and we also support customized interval providers), each with its own default format (that may be overriden using built-in or custom formatters as well.)
        let headerController = GanttChartHeaderController()
        headerController.rows = [
            GanttChartHeaderRow(.weeks(startingOn: .monday)),
            GanttChartHeaderRow(.days, format: .dayOfWeekShortAbbreviation)]
        
        // Initialize a Gantt Chart content controller specifying settings for the chart area: intervalHighlighters indicate the vertical lines to be drawn (such as between weeks and for the current time), scheduleHighlighters indicate the background highlighting to be applied (such as for weekend days), timeScale indicates the updating mode for item bars (time granularity), and hourWidth indicates the horizontal zoom level. Optionally, you can also set the scrollableTimeline to override the default timeline determined by items' intervals.
        let contentController = GanttChartContentController(itemManager: itemManager)
        contentController.intervalHighlighters = [
            TimeSelector(.weeks(startingOn: .monday)), TimeSelector(.time)]
        contentController.scheduleHighlighters = [ScheduleTimeSelector(.weekends)]
        contentController.timeScale = .intervalsWith(period: 15, in: .minutes)
        contentController.hourWidth = 2
        // contentController.scrollableTimeline = TimeRange(
        //     from: Time.current.weekStart, to: Time.current.weekFinish.adding(weeks: 4))
        
        // Finally, set up the main Gantt chart controller, linking the content and header controller objects together.
        let controller = GanttChartController(
            headerController: headerController, contentController: contentController)
        
        // Optionally, change the appearance theme of the entire component with a single line of code (built-in themes are standard, aqua, and jewel):
        // controller.theme = .jewel
        
        // Optionally, set individual style attributes for each of the content and header controller objects. Note, however, that the dark mode is not supported and the standard theme is not preserved if style attributes are manually specified, so you should override all style attributes in this case:
        // headerController.style.labelForegroundColor = .gray
        // contentController.style.attachmentForegroundColor = .gray
        // ...
        
        // Alternatively, and to support dark mode as well, define a custom theme with different styles for light and dark appearance using setStyleForTheme(_:mode:to) method of both content and header controllers, and apply that theme by setting controller.theme to .custom(name:) appropriately:
        // let themeName = "My"
        // var style = GanttChartContentStyle(.standard)
        // style.backgroundColor = Color(red: 0.5, green: 0.75, blue: 1, alpha: 0.125)
        // style.barFillColor = .orange
        // var darkStyle = GanttChartContentStyle(.standard, mode: .dark)
        // darkStyle.backgroundColor = Color(red: 0.25, green: 0.375, blue: 0.5, alpha: 0.25)
        // darkStyle.barFillColor = .orange
        // var headerStyle = GanttChartHeaderStyle(.standard)
        // headerStyle.labelForegroundColor = Color(red: 0.25, green: 0.5, blue: 0.75)
        // var darkHeaderStyle = GanttChartHeaderStyle(.standard, mode: .dark)
        // darkHeaderStyle.labelForegroundColor = Color(red: 0.5, green: 0.75, blue: 0.875)
        // contentController.setStyleForTheme(themeName, to: style)
        // contentController.setStyleForTheme(themeName, mode: .dark, to: darkStyle)
        // headerController.setStyleForTheme(themeName, to: headerStyle)
        // headerController.setStyleForTheme(themeName, mode: .dark, to: darkHeaderStyle)
        // controller.theme = .custom(name: themeName)
        
        // Set up the controller to the view:
        ganttChart.controller = controller
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

