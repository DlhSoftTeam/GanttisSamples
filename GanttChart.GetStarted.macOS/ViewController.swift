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
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

