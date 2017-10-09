//
//  TaskDoneViewController.swift
//  My Great Productivity App
//
//  Created by Ana Vitoria do Valle Costa on 4/7/17.
//  Copyright © 2017 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation
import UIKit

class   TaskDoneViewController:  UIViewController {
    var parentVC: NowViewController?
    
    @IBAction func plus1min(_ sender: Any) {
        parentVC?.updateTaskDuration(minutes: 1)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func plus5min(_ sender: Any) {
        parentVC?.updateTaskDuration(minutes: 5)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func plus10min(_ sender: Any) {
        parentVC?.updateTaskDuration(minutes: 10)
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func nextTask(_ sender: Any) {
        parentVC?.completeTask()
        self.navigationController?.popViewController(animated: true)
    }
}
