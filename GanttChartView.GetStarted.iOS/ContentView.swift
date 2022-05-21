//
//  ContentView.swift
//  GanttChartView.GetStarted.iOS
//
//  Created by DlhSoft on 21.05.2022.
//

import SwiftUI
import GanttisTouch

struct ContentView: View {
    @State var items = [GanttChartViewItem]()
    @State var dependencies = [GanttChartViewDependency]()
    @State var rowHeaders: [String?]? = nil
    @State var schedule = Schedule.continuous
    @State var theme = Theme.standard
    
    @State var lastChange = "none"
    @State var dateToAddTo = 2
    
    var body: some View {
        VStack(spacing: 0) {
            GanttChartView(
                items: $items,
                dependencies: $dependencies,
                schedule: schedule,
                headerRows: [
                    GanttChartHeaderRow(.weeks(startingOn: .monday)),
                    GanttChartHeaderRow(.days, format: .dayOfWeekShortAbbreviation)],
                scrollableTimeline: TimeRange(from: Time.current.weekStart,
                                              to: Time.current.adding(years: 1).weekFinish),
                scheduleHighlighters: [ScheduleTimeSelector(.weekends)],
                intervalHighlighters: [TimeSelector(.weeks(startingOn: .monday)), TimeSelector(.time)],
                timeScale: .intervalsWith(period: 15, in: .minutes),
                desiredScrollableRowCount: 50,
                rowHeaders: rowHeaders,
                rowHeadersWidth: 100,
                theme: theme,
                onItemAdded: { item in
                    lastChange = "\(item.label ?? "item") added"
                },
                onItemRemoved: { _ in
                    lastChange = "item removed"
                },
                onDependencyAdded: { dependency in
                    lastChange = "dependency added from \(dependency.from(considering: items)!.label ?? "item") to \(dependency.to(considering: items)!.label ?? "item")"
                },
                onDependencyRemoved: { _ in
                    lastChange = "dependency removed"
                },
                onTimeChanged: { item, _ in
                    lastChange = "time updated for \(item.label ?? "item")"
                },
                onCompletionChanged: { item, _ in
                    lastChange = "completion updated for \(item.label ?? "item")"
                },
                onRowChanged: { item, _ in
                    lastChange = "row updated for \(item.label ?? "item")"
                })
            Divider()
            HStack {
                Text("Total: \(items.count) items, \(dependencies.count) dependencies")
                Spacer()
                Text("Last change: \(lastChange)")
            }.padding(5)
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button("Add new") {
                    addNewItem()
                    lastChange = "added new item"
                    dateToAddTo += 1
                }
                Button("Update") {
                    updateAnItem()
                    lastChange = "updated an item"
                }
                Button("Remove dep.") {
                    removeAllDependencies()
                    lastChange = "removed all dependencies"
                }
                Spacer()
                Button("Theme") {
                    changeTheme()
                }
            }
        }
        .onAppear() {
            var items = [
                GanttChartViewItem(label: "A", row: 0, start: date(1), finish: date(2)),
                GanttChartViewItem(label: "B", row: 1, start: date(1), finish: date(3)),
                GanttChartViewItem(label: "C", row: 1, start: date(4), finish: date(6)),
                GanttChartViewItem(row: 1, start: date(10), finish: date(11)),
                GanttChartViewItem(row: 2, start: date(2), finish: date(12))]
            items[0].style.barFillColor = .darkGreen
            items[4].details = "Special item"
            items[1].completion = 1
            items[2].completion = 0.25
            items[2].type = .summary
            items[4].completion = 0.08
            for i in 3..<50 {
                items.append(GanttChartViewItem(label: String(i), row: i,
                                                start: date(i), finish: date(i + 1)))
            }
            items[6].attachment = "R"
            var dependencies = [
                GanttChartViewDependency(from: items[2].id, to: items[4].id),
                GanttChartViewDependency(from: items[5].id, to: items[6].id, type: .fromStartToStart),
                GanttChartViewDependency(from: items[7].id, to: items[8].id, type: .fromFinishToFinish),
                GanttChartViewDependency(from: items[9].id, to: items[10].id, type: .fromStartToFinish)]
            dependencies[0].style.lineColor = .darkGreen
            dependencies[3].details = "Special dependency"
            items.append(GanttChartViewItem(row: 3, time: date(6), type: .milestone))
            dependencies.append(GanttChartViewDependency(from: items[5].id, to: items[items.count-1].id))
            self.items = items
            self.dependencies = dependencies
            var rowHeaders = [String?]()
            for i in 0..<50 {
                rowHeaders.append("Res. \(i+1)")
            }
            self.rowHeaders = rowHeaders
        }
    }
    
    func configure(controller: GanttChartController) {
        let headerController = controller.headerController
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
        let contentController = controller.contentController
        contentController.intervalHighlighters = [
            TimeSelector(.weeks(startingOn: .monday)), TimeSelector(.time)]
        contentController.scheduleHighlighters = [ScheduleTimeSelector(.weekends)]
        contentController.timeScale = .intervalsWith(period: 15, in: .minutes)
    }
    
    func addNewItem() {
        items.append(
            GanttChartViewItem(label: "New", row: 0,
                               start: date(dateToAddTo), finish: date(dateToAddTo + 1)))
    }
    func updateAnItem() {
        items[1].label = "Updated at :\(String(format: "%02d", Time.current.second))"
    }
    func removeAllDependencies() {
        dependencies.removeAll()
    }
    func changeTheme() {
        theme = theme == .standard ? .jewel : .standard
    }
}

func date(_ day: Int) -> Time {
    return Time().weekStart.adding(days: day)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
