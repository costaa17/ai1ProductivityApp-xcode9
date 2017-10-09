//
//  TodayViewController.swift
//  My Great Productivity App
//
//  Created by Ana Vitoria do Valle Costa on 2/12/17.
//  Copyright © 2017 Ana Vitoria do Valle Costa. All rights reserved.
//

import Foundation
import UIKit

class TodayViewController: UIViewController {
    
    @IBOutlet weak var tableView: TasksTableViewController!
    
    override func viewDidLoad() {
        tableView.delegate = tableView
        tableView.dataSource = tableView
        tableView.parent = self
        
        let longpress = UILongPressGestureRecognizer(target: tableView, action: Selector(("longPressGestureRecognized:")))
        tableView.addGestureRecognizer(longpress)
        
        tableView.reloadData()
    }
    
    @IBAction func backButton(_ sender: Any) {
        backButtonUpdateCur()
        //self.navigationController?.dismiss(animated: true)
        dismiss(animated: true)
    }
    
    override func editTask(index: Int) {
        performSegue(withIdentifier: "editTodayTask", sender: self)
    }
}
