//
//  ContentView.swift
//  Shared
//
//  Created by DlhSoft on 02.08.2021.
//

import SwiftUI

struct ContentView: View {
    @StateObject var adapter: GanttChartAdapter = {
        var items = [
            Item(label: "A", row: 0, start: 1, finish: 2),
            Item(label: "B", row: 1, start: 1, finish: 3),
            Item(label: "C", row: 1, start: 4, finish: 6),
            Item(row: 1, start: 10, finish: 11),
            Item(row: 2, start: 2, finish: 12)]
        items.first!.style.barFillColor = .green
        items.last!.details = "Special item"
        items[1].completion = 1
        items[2].completion = 0.25
        items[2].type = .summary
        items[4].completion = 0.08
        for i in 3..<100 {
            items.append(Item(label: String(i), row: i,
                              start: i, finish: i + 1))
        }
        items[6].attachment = "R"
        var dependencies = [
            Dependency(from: items[2], to: items[4]),
            Dependency(from: items[5], to: items[6], type: .fromStartToStart),
            Dependency(from: items[7], to: items[8], type: .fromFinishToFinish),
            Dependency(from: items[9], to: items[10], type: .fromStartToFinish)]
        dependencies.first!.style.lineColor = .green
        dependencies.last!.details = "Special dependency"
        items.append(Item(row: 3, time: 6, type: .milestone))
        dependencies.append(Dependency(from: items[5], to: items.last!))
        return GanttChartAdapter(items: items, dependencies: dependencies)
    }()
    
    var body: some View {
        VStack(spacing: .zero) {
            GanttChart(controller: adapter.controller)
            HStack {
                Text("Last change: \(adapter.lastChange)")
                Spacer()
                Button(action: adapter.changeBackgroundColor) {
                    Text("Change background color")
                }
            }.padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
