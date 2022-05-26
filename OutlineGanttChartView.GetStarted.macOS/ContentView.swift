//
//  ContentView.swift
//  OutlineGanttChartView.GetStarted.macOS
//
//  Created by DlhSoft on 21.05.2022.
//

import SwiftUI
import Ganttis

struct ContentView: View {
    @State var rows = [OutlineGanttChartViewRow]()
    @State var chartDependencies = [OutlineGanttChartViewDependency]()
    @State var schedule = Schedule.continuous
    @State var theme = Theme.standard
    
    let now = Time.current
    
    @State var lastChange = "none"
    @State var dateToAddTo = 2
    
    var body: some View {
        VStack(spacing: 0) {
            OutlineGanttChartView(
                rows: $rows,
                chartDependencies: $chartDependencies,
                columns: [
                    .outline(title: "Tasks"),
                    .start, .finish, .completion,
                    .attachment(title: "Assignments"),
                    .value("Custom", title: "Custom", alignment: .left, monospacedFont: false, isEditable: true),
                    .details],
                outlineHeader: "Project",
                schedule: schedule,
                headerRows: [
                    GanttChartHeaderRow(.weeks(startingOn: .monday)),
                    GanttChartHeaderRow(.days, format: .dayOfWeekShortAbbreviation)],
                scrollableTimeline: TimeRange(from: Time.current.weekStart,
                                              to: Time.current.adding(years: 1).weekFinish),
                scheduleHighlighters: [ScheduleTimeSelector(.weekends)],
                intervalHighlighters: [TimeSelector(.weeks(startingOn: .monday)), TimeSelector(.time)],
                timeScale: .intervalsWith(period: 15, in: .minutes),
                theme: theme,
                onChartDependencyAdded: { dependency in
                    lastChange = "dependency added from \(dependency.from.label ?? "item") to \(dependency.to.label ?? "item")"
                },
                onChartDependencyRemoved: { _ in
                    lastChange = "dependency removed"
                },
                onTimeChanged: { item, _ in
                    lastChange = "time updated for \(item.label ?? "item")"
                },
                onCompletionChanged: { item, _ in
                    lastChange = "completion updated for \(item.label ?? "item")"
                },
                onCellValueChanged: { item, column, _ in
                    lastChange = "value of cell \(column.title) updated for \(item.label ?? "item")"
                })
            Divider()
            HStack {
                Text("Total: \(rows.count) rows, \(chartDependencies.count) dependencies")
                Spacer()
                Text("Last change: \(lastChange)")
            }.padding(5)
        }
        .toolbar {
            ToolbarItemGroup {
                Button("Add new row") {
                    addNewRow()
                    lastChange = "added new row"
                    dateToAddTo += 1
                }
                Button("Update an item") {
                    updateAnItem()
                    lastChange = "updated an item"
                }
                Button("Remove all dependencies") {
                    removeAllDependencies()
                    lastChange = "removed all dependencies"
                }
                Button("Change theme") {
                    changeTheme()
                }
            }
        }
        .onAppear() {
            var rows: [OutlineGanttChartViewRow] = [
                OutlineGanttChartViewRow(
                    label: "Task 1",
                    chartItems: [
                        OutlineGanttChartViewItem(
                            label: "Task 1",
                            start: now, finish: now.adding(days: 3),
                            details: "Task 1 details",
                            type: .summary)],
                    children: [
                        OutlineGanttChartViewRow(
                            chartItems: [
                                OutlineGanttChartViewItem(
                                    label: "Task 1.1",
                                    start: now, finish: now.adding(days: 2),
                                    completion: 0.5, attachment: "Resource 1",
                                    details: "Task 1.1 details"),
                                OutlineGanttChartViewItem(
                                    time: now.adding(days: 3), type: .milestone)])]),
                OutlineGanttChartViewRow(
                    label: "Task 2",
                    chartItems: [
                        OutlineGanttChartViewItem(
                            label: "Task 2",
                            start: now.adding(days: 1), finish: now.adding(days: 4),
                            completion: 0.25, attachment: "Resource 2",
                            details: "Task 2 details")])]
            
            for i in 3...400 {
                rows.append(OutlineGanttChartViewRow(
                    label: "Task \(i)",
                    chartItems: [OutlineGanttChartViewItem(
                        label: "Task \(i)",
                        start: now.adding(hours: Double(i * 4)),
                        finish: now.adding(hours: Double(i * 9)),
                        type: i % 2 == 0 ? .summary : nil)],
                    children: i % 2 == 0 ? [
                        OutlineGanttChartViewRow(
                            chartItems: [
                                OutlineGanttChartViewItem(
                                    label: "Task \(i).1",
                                    start: now.adding(hours: Double(i * 4)),
                                    finish: now.adding(hours: Double(i * 8)))]),
                        OutlineGanttChartViewRow(
                            chartItems: [
                                OutlineGanttChartViewItem(
                                    label: "Task \(i).2",
                                    start: now.adding(hours: Double(i * 4)),
                                    finish: now.adding(hours: Double(i * 9)))])] : []))
            }
            for i in 3...15 {
                rows[3].children.append(OutlineGanttChartViewRow(
                    label: "Task 4.\(i)",
                    chartItems: [OutlineGanttChartViewItem(
                        label: "Task 4.\(i)",
                        start: now.adding(hours: Double(i * 4)),
                        finish: now.adding(hours: Double(i * 9)),
                        type: i % 2 == 0 ? .summary : nil)],
                    children: i % 2 == 0 ? [
                        OutlineGanttChartViewRow(
                            chartItems: [
                                OutlineGanttChartViewItem(
                                    label: "Task 4.\(i).1",
                                    start: now.adding(hours: Double(i * 4)),
                                    finish: now.adding(hours: Double(i * 8)))]),
                        OutlineGanttChartViewRow(
                            chartItems: [
                                OutlineGanttChartViewItem(
                                    label: "Task 4.\(i).2",
                                    start: now.adding(hours: Double(i * 4)),
                                    finish: now.adding(hours: Double(i * 9)))])] : []))
            }
            rows[3].chartItems[0].start = now.adding(hours: 3 * 4)
            rows[3].chartItems[0].finish = now.adding(hours: 15 * 9)
            var chartDependencies: [OutlineGanttChartViewDependency] = [
                OutlineGanttChartViewDependency(
                    from: rows[0].children[0].chartItems[0],
                    to: rows[1].chartItems[0],
                    type: .fromStartToStart),
                OutlineGanttChartViewDependency(
                    from: rows[0].children[0].chartItems[0],
                    to: rows[0].children[0].chartItems[1]),
                OutlineGanttChartViewDependency(
                    from: rows[1].chartItems[0],
                    to: rows[2].chartItems[0])]
            for i in stride(from: 3, to: rows.count / 2, by: 2) {
                chartDependencies.append(OutlineGanttChartViewDependency(
                    from: rows[i - 1].chartItems[0],
                    to: rows[i].chartItems[0]))
            }
            rows[1].values["Custom"] = "Second"
            self.rows = rows
            self.chartDependencies = chartDependencies
        }
    }
    
    func addNewRow() {
        rows.insert(OutlineGanttChartViewRow(
            label: "New",
            chartItems: [OutlineGanttChartViewItem(
                start: now,
                finish: now.adding(days: 1))]), at: 0)
    }
    func updateAnItem() {
        let second = String(format: "%02d", Time.current.second)
        rows[1].label = "Updated at: \(second)"
        rows[1].chartItems[0].attachment = ":\(second)"
        rows[1].chartItems[0].finish = rows[1].chartItems[0].finish.adding(hours: 1)
        rows[1].chartItems[0].start = rows[1].chartItems[0].start.adding(hours: 1)
    }
    func removeAllDependencies() {
        chartDependencies.removeAll()
    }
    func changeTheme() {
        theme = theme == .standard ? .jewel : .standard
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
