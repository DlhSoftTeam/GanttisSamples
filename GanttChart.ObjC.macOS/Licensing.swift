//
//  Licensing.swift
//  GanttChart.ObjC.macOS
//
//  Created by DlhSoft on 19/10/2019.
//

import Foundation
import Ganttis

public class GanttisLicense: NSObject {
    /// Called upon AppDelegate initialization.
    public override init() {
        Ganttis.license = "..."
    }
}
