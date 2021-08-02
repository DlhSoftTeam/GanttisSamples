//
//  Items.swift
//  GanttisSamples
//
//  Created by DlhSoft on 02.08.2021.
//

import Foundation

class Item {
    init(label: String? = nil, row: Int, start: DayNumber, finish: DayNumber, type: ItemType? = nil) {
        self.label = label
        self.row = row
        self.start = start
        self.finish = finish
        if let type = type {
            self.type = type
        }
    }
    convenience init(label: String? = nil, row: Int, time: DayNumber, type: ItemType? = nil) {
        self.init(label: label, row: row, start: time, finish: time, type: type)
    }
    var label: String?
    var row: Int
    var start, finish: DayNumber
    var completion: Double = 0
    var attachment: String?
    var details: String?
    var type = ItemType.standard
    var style = ItemStyle()
}
typealias DayNumber = Int
enum ItemType {
    case standard
    case milestone
    case summary
}
struct ItemStyle {
    var barFillColor: Color?
}

class Dependency {
    init(from: Item, to: Item, type: DependencyType? = nil) {
        self.from = from
        self.to = to
        if let type = type {
            self.type = type
        }
    }
    var from: Item
    var to: Item
    var details: String?
    var type = DependencyType.fromFinishToStart
    var style = DependencyStyle()
}
enum DependencyType {
    case fromFinishToStart
    case fromStartToStart
    case fromFinishToFinish
    case fromStartToFinish
}
struct DependencyStyle {
    var lineColor: Color?
}
struct Color {
    var red, green, blue: Double
    var alpha = 1.0
    static var black = Color(red: 0, green: 0, blue: 0)
    static var red = Color(red: 0.5, green: 0, blue: 0)
    static var green = Color(red: 0, green: 0.5, blue: 0)
    static var blue = Color(red: 0, green: 0, blue: 0.5)
    static var gray = Color(red: 0.5, green: 0.5, blue: 0.5)
    static var white = Color(red: 1, green: 1, blue: 1)
}
