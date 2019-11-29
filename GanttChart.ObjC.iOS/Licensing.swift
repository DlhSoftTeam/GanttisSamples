//
//  Licensing.swift
//  GanttChart.ObjC.iOS
//
//  Created by DlhSoft on 21/10/2019.
//

import Foundation
import GanttisTouch

public class GanttisLicense: NSObject {
    /// Called upon AppDelegate initialization.
    public override init() {
        GanttisTouch.license = "..."
    }
}
