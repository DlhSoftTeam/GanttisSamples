//
//  ViewController.swift
//  GanttChart.CustomBars.iOS
//
//  Created by DlhSoft on 02.08.2021.
//

import UIKit
import GanttisTouch

class ViewController: UIViewController {
    @IBOutlet var ganttChart: GanttChart!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        var items: [GanttChartItem] = []
        for i in 0..<100 {
            let item = GanttChartItem(
                label: "Item \(i + 1)",
                row: i,
                start: Time.current.weekStart.adding(days: i),
                finish: Time.current.weekStart.adding(days: i * 2 + 1),
                completion: Double(i) / 100,
                attachment: "Resource \(i % 3 + 1)",
                details: "Details for item \(i + 1)",
                context: CustomContext(
                    allocation: 1.25 - Double(i % 5) / 10,
                    baseline: TimeRange(from: Time.current.weekStart.adding(days: max(1, i - 2)),
                                        to: Time.current.weekStart.adding(days: max(2, i * 2 - 1)))
                ))
            if i == 3 {
                item.label = ""
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
        
        var dependencies: [GanttChartDependency] = []
        for i in 3..<100 {
            let dependency = GanttChartDependency(
                from: items[i - 1],
                to: items[i],
                details: "Dependency from item \(i) to item \(i + 1)")
            if i == 7 {
                dependency.settings.isReadOnly = true
                dependency.details = "\(dependency.details!) (read only)"
            }
            if i % 3 == 0 {
                dependency.style.lineColor = .darkGreen
            }
            dependencies.append(dependency)
        }
        
        let itemManager = GanttChartItemSource(items: items, dependencies: dependencies)
        
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
        
        itemManager.isColumn = true
        
        let headerController = GanttChartHeaderController()
        headerController.rows = [
            GanttChartHeaderRow(.weeks(startingOn: .monday)),
            GanttChartHeaderRow(.days, format: .dayOfWeekShortAbbreviation)]
        
        let contentController = GanttChartContentController(itemManager: itemManager)
        contentController.intervalHighlighters = [
            TimeSelector(.weeks(startingOn: .monday)), TimeSelector(.time)]
        contentController.scheduleHighlighters = [ScheduleTimeSelector(.weekends)]
        contentController.timeScale = .intervalsWith(period: 15, in: .minutes)
        contentController.hourWidth = 2
                
        let controller = GanttChartController(
            headerController: headerController, contentController: contentController)
        
        ganttChart.controller = controller
        
        // Setup the presenter to this instance, for it to be used upon drawing the Gantt chart item bars.
        contentController.presenter = customGanttChartContentPresenter
        // Ensure regional backgrounds are drawn, in order to draw baseline bars behind item bars in the chart.
        contentController.style.regionalBackgroundColor = Self.clearColor
        // Customize other settings as appropriate for drawing bars with different heights.
        contentController.settings.showsLabels = false
        contentController.settings.showsCompletionBars = false
        contentController.style.cornerRadius = 1
    }
    
    private lazy var customGanttChartContentPresenter = CustomGanttChartContentPresenter(viewController: self)
    static let clearColor = GanttisTouch.Color(red: 0.5, green: 0.5, blue: 0.5, alpha: 0)


}

// Defines specific supplemental properties for items.
struct CustomContext {
    // Used to draw bars of different heights, such as in a load chart.
    var allocation: Double = 1
    // Used to define the time interval of the baseline bars.
    var baseline: TimeRange
}

// Specific presenter that generally delegates drawing to the underlying content view, injecting certain custom drawing algorithms to display baseline bars and adapt item bars to their context height percent values.
class CustomGanttChartContentPresenter: GanttChartContentPresenter {
    init(viewController: ViewController) {
        self.ganttChartContent = viewController.ganttChart.content
    }
    private let ganttChartContent: GanttChartContent
    func drawBackground(color: GanttisTouch.Color, size: Size) {
        ganttChartContent.drawBackground(color: color, size: size)
    }
    func drawBorder(in rectangle: GanttisTouch.Rectangle, line: Line, lineWidth: Double, color: GanttisTouch.Color) {
        ganttChartContent.drawBorder(in: rectangle, line: line, lineWidth: lineWidth, color: color)
    }
    func drawBackground(for row: Row, in rectangle: GanttisTouch.Rectangle, color: GanttisTouch.Color) {
        ganttChartContent.drawBackground(for: row, in: rectangle, color: color)
    }
    func drawBorder(for row: Row, in rectangle: GanttisTouch.Rectangle, line: Line, lineWidth: Double, color: GanttisTouch.Color) {
        ganttChartContent.drawBorder(for: row, in: rectangle, line: line, lineWidth: lineWidth, color: color)
    }
    func drawRegionalBackground(for item: GanttChartItem, in rectangle: GanttisTouch.Rectangle, color: GanttisTouch.Color) {
        // Custom draw of baseline bars under item bars.
        ganttChartContent.drawRegionalBackground(for: item, in: rectangle, color: color)
        drawBaseline(for: item)
    }
    func draw(bar: GanttChartBar) {
        ganttChartContent.draw(bar: bar)
    }
    func drawBar(for item: GanttChartItem, in rectangle: GanttisTouch.Rectangle, fillColor: GanttisTouch.Color, secondaryFillColor: GanttisTouch.Color, strokeColor: GanttisTouch.Color?, strokeWidth: Double, cornerRadius: Double, isHighlighted: Bool, isFocused: Bool, isSelected: Bool, highlightColor: GanttisTouch.Color, focusColor: GanttisTouch.Color, selectionColor: GanttisTouch.Color, highlightWidth: Double, focusWidth: Double, selectionWidth: Double, allowsMoving: Bool, allowsResizing: Bool, allowsResizingAtStart: Bool, allowsMovingVertically: Bool, thumbDistance: Double) {
        // Custom draw of bars respecting their context height percent.
        drawCustomHeightBar(for: item, in: rectangle, fillColor: fillColor, secondaryFillColor: secondaryFillColor, strokeColor: strokeColor, strokeWidth: strokeWidth, cornerRadius: cornerRadius, isHighlighted: isHighlighted, isFocused: isFocused, isSelected: isSelected, highlightColor: highlightColor, focusColor: focusColor, selectionColor: selectionColor, highlightWidth: highlightWidth, focusWidth: focusWidth, selectionWidth: selectionWidth, allowsMoving: allowsMoving, allowsResizing: allowsResizing, allowsResizingAtStart: allowsResizingAtStart, allowsMovingVertically: allowsMovingVertically, thumbDistance: thumbDistance)
    }
    func drawSummaryBar(for item: GanttChartItem, in rectangle: GanttisTouch.Rectangle, fillColor: GanttisTouch.Color, secondaryFillColor: GanttisTouch.Color, strokeColor: GanttisTouch.Color?, strokeWidth: Double, triangleInset: Double, triangleScale: Double, isExpanded: Bool, isHighlighted: Bool, isFocused: Bool, isSelected: Bool, highlightColor: GanttisTouch.Color, focusColor: GanttisTouch.Color, selectionColor: GanttisTouch.Color, highlightWidth: Double, focusWidth: Double, selectionWidth: Double, allowsMoving: Bool, allowsResizing: Bool, allowsResizingAtStart: Bool, allowsMovingVertically: Bool, thumbDistance: Double) {
        ganttChartContent.drawSummaryBar(for: item, in: rectangle, fillColor: fillColor, secondaryFillColor: secondaryFillColor, strokeColor: strokeColor, strokeWidth: strokeWidth, triangleInset: triangleInset, triangleScale: triangleScale, isExpanded: isExpanded, isHighlighted: isHighlighted, isFocused: isFocused, isSelected: isSelected, highlightColor: highlightColor, focusColor: focusColor, selectionColor: selectionColor, highlightWidth: highlightWidth, focusWidth: focusWidth, selectionWidth: selectionWidth, allowsMoving: allowsMoving, allowsResizing: allowsResizing, allowsResizingAtStart: allowsResizingAtStart, allowsMovingVertically: allowsMovingVertically, thumbDistance: thumbDistance)
    }
    func drawMilestone(for item: GanttChartItem, in rectangle: GanttisTouch.Rectangle, fillColor: GanttisTouch.Color, secondaryFillColor: GanttisTouch.Color, strokeColor: GanttisTouch.Color?, strokeWidth: Double, isHighlighted: Bool, isFocused: Bool, isSelected: Bool, highlightColor: GanttisTouch.Color, focusColor: GanttisTouch.Color, selectionColor: GanttisTouch.Color, highlightWidth: Double, focusWidth: Double, selectionWidth: Double, allowsMoving: Bool, allowsMovingVertically: Bool, thumbDistance: Double) {
        ganttChartContent.drawMilestone(for: item, in: rectangle, fillColor: fillColor, secondaryFillColor: secondaryFillColor, strokeColor: strokeColor, strokeWidth: strokeWidth, isHighlighted: isHighlighted, isFocused: isFocused, isSelected: isSelected, highlightColor: highlightColor, focusColor: focusColor, selectionColor: selectionColor, highlightWidth: highlightWidth, focusWidth: focusWidth, selectionWidth: selectionWidth, allowsMoving: allowsMoving, allowsMovingVertically: allowsMovingVertically, thumbDistance: thumbDistance)
    }
    func drawCompletionBar(for item: GanttChartItem, in rectangle: GanttisTouch.Rectangle, fillColor: GanttisTouch.Color, secondaryFillColor: GanttisTouch.Color, strokeColor: GanttisTouch.Color?, strokeWidth: Double, cornerRadius: Double, allowsResizing: Bool, thumbDistance: Double) {
        ganttChartContent.drawCompletionBar(for: item, in: rectangle, fillColor: fillColor, secondaryFillColor: secondaryFillColor, strokeColor: strokeColor, strokeWidth: strokeWidth, cornerRadius: cornerRadius, allowsResizing: allowsResizing, thumbDistance: thumbDistance)
    }
    func drawBarLabel(for item: GanttChartItem, in rectangle: GanttisTouch.Rectangle, text: String, foregroundColor: GanttisTouch.Color, alignment: GanttisTouch.TextAlignment, font: GanttisTouch.Font) {
        ganttChartContent.drawBarLabel(for: item, in: rectangle, text: text, foregroundColor: foregroundColor, alignment: alignment, font: font)
    }
    func drawAttachmentLabel(for item: GanttChartItem, in rectangle: GanttisTouch.Rectangle, text: String, foregroundColor: GanttisTouch.Color, font: GanttisTouch.Font) {
        ganttChartContent.drawAttachmentLabel(for: item, in: rectangle, text: text, foregroundColor: foregroundColor, font: font)
    }
    func draw(dependencyLine: GanttChartDependencyLine) {
        ganttChartContent.draw(dependencyLine: dependencyLine)
    }
    func drawDependencyLine(for dependency: GanttChartDependency, as polyline: Polyline, color: GanttisTouch.Color, width: Double, arrowWidth: Double, arrowLength: Double, isHighlighted: Bool, isFocused: Bool, isSelected: Bool, highlightWidth: Double, focusWidth: Double, selectionWidth: Double) {
        ganttChartContent.drawDependencyLine(for: dependency, as: polyline, color: color, width: width, arrowWidth: arrowWidth, arrowLength: arrowLength, isHighlighted: isHighlighted, isFocused: isFocused, isSelected: isSelected, highlightWidth: highlightWidth, focusWidth: focusWidth, selectionWidth: selectionWidth)
    }
    func drawDependencyLineThumb(for item: GanttChartItem, type: GanttChartDependencyEndType, center: Point, radius: Double, color: GanttisTouch.Color) {
        ganttChartContent.drawDependencyLineThumb(for: item, type: type, center: center, radius: radius, color: color)
    }
    func drawTemporaryDependencyLine(from: GanttChartItem, to: GanttChartItem?, type: GanttChartDependencyType, as polyline: Polyline, color: GanttisTouch.Color, width: Double, arrowWidth: Double, arrowLength: Double, dashWidth: Double) {
        ganttChartContent.drawTemporaryDependencyLine(from: from, to: to, type: type, as: polyline, color: color, width: width, arrowWidth: arrowWidth, arrowLength: arrowLength, dashWidth: dashWidth)
    }
    func drawTemporaryBar(in rectangle: GanttisTouch.Rectangle, color: GanttisTouch.Color, cornerRadius: Double, dashWidth: Double) {
        ganttChartContent.drawTemporaryBar(in: rectangle, color: color, cornerRadius: cornerRadius, dashWidth: dashWidth)
    }
    func drawTimeArea(for highlighter: ScheduleTimeSelector, in rectangle: GanttisTouch.Rectangle, fillColor: GanttisTouch.Color) {
        ganttChartContent.drawTimeArea(for: highlighter, in: rectangle, fillColor: fillColor)
    }
    func drawTimeArea(for highlighter: TimeSelector, in rectangle: GanttisTouch.Rectangle, backgroundColor: GanttisTouch.Color) {
        ganttChartContent.drawTimeArea(for: highlighter, in: rectangle, backgroundColor: backgroundColor)
    }
    func drawTimeAreaBorder(for highlighter: TimeSelector, in rectangle: GanttisTouch.Rectangle, line: Line, lineWidth: Double, color: GanttisTouch.Color) {
        ganttChartContent.drawTimeAreaBorder(for: highlighter, in: rectangle, line: line, lineWidth: lineWidth, color: color)
    }
    func drawTimeAreaLabel(for highlighter: TimeSelector, in rectangle: GanttisTouch.Rectangle, text: String, foregroundColor: GanttisTouch.Color, alignment: GanttisTouch.TextAlignment, font: GanttisTouch.Font, verticalAlignment: VerticalTextAlignment) {
        ganttChartContent.drawTimeAreaLabel(for: highlighter, in: rectangle, text: text, foregroundColor: foregroundColor, alignment: alignment, font: font, verticalAlignment: verticalAlignment)
    }
    func toolTip(for item: GanttChartItem) -> String? {
        ganttChartContent.toolTip(for: item)
    }
    func toolTip(for dependency: GanttChartDependency) -> String? {
        ganttChartContent.toolTip(for: dependency)
    }
    private func drawBaseline(for item: GanttChartItem) {
        guard item.isStandard, let context = item.context as? CustomContext else { return }
        guard let ganttChartContentController = ganttChartContent.controller else { return }
        let style = ganttChartContentController.actualStyle
        let strokeWidth = style.barStrokeWidth / 2, cornerRadius = style.cornerRadius
        let rectangle = Rectangle(
            left: ganttChartContentController.x(of: context.baseline.start),
            top: ganttChartContentController.top(of: item.row),
            right: ganttChartContentController.x(of: context.baseline.finish),
            bottom: ganttChartContentController.bottom(of: item.row))
            .insetBy(dx: 0, dy: style.verticalBarInset)
            .movedBy(dx: 0, dy: -style.verticalBarInset / 2)
        let color = style.barFillColor, clear = ViewController.clearColor
        ganttChartContent.drawBar(for: item, in: rectangle, fillColor: clear, secondaryFillColor: clear, strokeColor: color, strokeWidth: strokeWidth, cornerRadius: cornerRadius, isHighlighted: false, isFocused: false, isSelected: false, highlightColor: clear, focusColor: clear, selectionColor: clear, highlightWidth: 0, focusWidth: 0, selectionWidth: 0, allowsMoving: false, allowsResizing: false, allowsResizingAtStart: false, allowsMovingVertically: false, thumbDistance: 0)
    }
    private func drawCustomHeightBar(for item: GanttChartItem, in rectangle: GanttisTouch.Rectangle, fillColor: GanttisTouch.Color, secondaryFillColor: GanttisTouch.Color, strokeColor: GanttisTouch.Color?, strokeWidth: Double, cornerRadius: Double, isHighlighted: Bool, isFocused: Bool, isSelected: Bool, highlightColor: GanttisTouch.Color, focusColor: GanttisTouch.Color, selectionColor: GanttisTouch.Color, highlightWidth: Double, focusWidth: Double, selectionWidth: Double, allowsMoving: Bool, allowsResizing: Bool, allowsResizingAtStart: Bool, allowsMovingVertically: Bool, thumbDistance: Double) {
        let defaultHeight = ganttChartContent.controller.rowHeight, maxHeightPercent = 1.25
        var heightPercent = 1.0
        if item.isStandard, let context = item.context as? CustomContext {
            heightPercent = max(0, min(maxHeightPercent, context.allocation))
        }
        let margin = defaultHeight * (maxHeightPercent - heightPercent) / 2
        ganttChartContent.drawBar(for: item,
                in: Rectangle(left: rectangle.left, top: rectangle.top + margin,
                              right: rectangle.right, bottom: rectangle.bottom - margin),
                fillColor: fillColor, secondaryFillColor: secondaryFillColor, strokeColor: strokeColor, strokeWidth: strokeWidth, cornerRadius: cornerRadius, isHighlighted: isHighlighted, isFocused: isFocused, isSelected: isSelected, highlightColor: highlightColor, focusColor: focusColor, selectionColor: selectionColor, highlightWidth: highlightWidth, focusWidth: focusWidth, selectionWidth: selectionWidth, allowsMoving: allowsMoving, allowsResizing: allowsResizing, allowsResizingAtStart: allowsResizingAtStart, allowsMovingVertically: allowsMovingVertically, thumbDistance: thumbDistance)
    }
}
