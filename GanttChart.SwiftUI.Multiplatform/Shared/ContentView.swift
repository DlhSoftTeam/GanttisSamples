//
//  ContentView.swift
//  Shared
//
//  Created by DlhSoft on 02.08.2021.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var adapter: GanttChartAdapter
    
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
